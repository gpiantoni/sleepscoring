function sleepscoring(info, opt)
%SLEEPSCORING do sleep scoring on EGI data without modifying the data
% The function reads the data directly from disk and keeps the scoring
% information separate from the data. There are two types of parameters for
% sleep scoring:
% 1- Parameters which is specific to the dataset ('info') 
% 2- Parameters about the visualization, not specific to the dataset ('opt')
%
% The two structures are saved and dealt with differently. 
% 1- INFO contains all the sleep scoring and other information specific to
%    the dataset, as it's stored in a .MAT file as structure. It's saved
%    every time you modify it (f.e. by changing sleep scoring).
% 2- OPT contains all the information about visualization, it can be stored
%    in a .m file (such as "opt_svui.m") or in a .MAT file as structure.
%    See PREPARE_OPT for more information
%    This structure is NOT saved automatically. 
%
% Use as:
%   SLEEPSCORING uses default "opt_svui.m" in folder "preferences"
% 
%   SLEEPSCORING(INFO) where INFO contains at least a field called 
%                     .dataset which points to the dataset to read
%                     If you specify a .fileinfo, it'll save the INFO
%                     variable in the file .fileinfo.
%
%   SLEEPSCORING(INFO, OPT) where OPT is a file similar to "opt_svui.m",
%                           but modified by you for your parameters 
%   SLEEPSCORING(INFO, OPT) where OPT is a .MAT file with a "opt" variable
%                           saved from a previous analysis 
%   SLEEPSCORING(INFO, OPT) where OPT is the "opt" variable from a previous
%                           analysis 
%  
% SLEEPSCORING can only run in one window at the time. If you want to run
% two sessions at the same time, open a new Matlab.

%TODO:
% - multiple windows
% - automatic detection of SW and spindles
% - automatic scoring
% - notes for each epoch
% - can only ADD markers, not delete them

%---------------------------------------------------------%
%-GUI FUNCTION
%---------------------------------------------------------%

%-------------------------------------%
%-CHECK INPUT
ftdir = which('ft_read_header');
if strcmp(ftdir, '')
  error('Please add fieldtrip folder and execute ''ft_defaults''')
end

if nargin < 2 || isempty(opt)
  opt = [fileparts(mfilename('fullpath')) filesep 'preference' filesep 'opt_svui.m']; % default OPT
end
%-------------------------------------%

%-------------------------------------%
%-OPT: preferences
opt = prepare_opt(opt);
%-------------------------------------%

%-------------------------------------%
%-create new figure
h = findobj('tag', 'sleepscoring');
if h; delete(h); end

opt.h.main = figure;
set(opt.h.main, 'tag', 'sleepscoring', 'name', 'Sleep Scoring', 'numbertitle', 'off', ...
  'closerequestfcn', @cb_closemain)

set(opt.h.main, 'KeyPressFcn', @cb_shortcuts)
%-------------------------------------%

%-------------------------------------%
%-PANELS
%-----------------%
%-create main panels
opt.h.data = uipanel('Title', 'Sleep Data', 'FontSize', 12, 'tag', 'p_data', ...
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.u opt.width.l opt.height.u]);

opt.h.hypno = uipanel('Title', 'Recording', 'FontSize', 12, 'tag', 'p_hypno',...
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.d opt.width.l opt.height.d]);

opt.h.info = uipanel('Title', 'Information', 'FontSize', 12, 'tag', 'p_info',...
  'Position', [opt.marg.r opt.marg.u opt.width.r opt.height.u]);

opt.h.fft = uipanel('Title', 'PowerSpectrum', 'FontSize', 12, 'tag', 'p_fft', ...
  'BackgroundColor','white', ...
  'Position', [opt.marg.r opt.marg.d opt.width.r opt.height.d]);

%-------%
%-create axes
opt.axis.data = axes('parent', opt.h.data, 'vis', 'off');
opt.axis.hypno = axes('parent', opt.h.hypno, 'vis', 'off');
opt.axis.fft = axes('parent', opt.h.fft, 'vis', 'off');
%-------%
%-----------------%

%-----------------%
%-create button and various items in the information panel
%-------%
%-info
uicontrol(opt.h.info, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .95 .9 .05], 'str', 'Dataset:', 'tag', 'name_info');
[~, optname] = fileparts(opt.optfile);
uicontrol(opt.h.info, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .9 .9 .05], 'str', ['OPT: ' optname], 'tag', 'name_opt');
%-------%

%-------%
%-change epochs
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .75 .25 .1], 'str', '<<', ...
  'call', @cb_bb);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .75 .30 .1], 'str', '', 'tag', 'epochnumber', ...
  'call', @cb_epoch); 
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .75 .25 .1], 'str', '>>', ...
  'call', @cb_ff);
%-------%

%-------%
%-scaling
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .6 .25 .1], 'str', '+', ...
  'call', @cb_yu);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .6 .30 .1], 'str', num2str(opt.ylim(2)), 'tag', 'ylimval', ...
  'call', @cb_ylim);
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .6 .25 .1], 'str', '-', ...
  'call', @cb_yd);
%-------%

%-------%
%-grid
uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.05 .45 .4 .1], 'str', '75uV', ...
  'val', opt.grid75, 'call', @cb_grid75);

uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.55 .45 .4 .1], 'str', '1s', ...
  'val', opt.grid1s, 'call', @cb_grid1s);
%-----------------%  
%-------------------------------------%

%-------------------------------------%
%-Menu bar
set(opt.h.main, 'Menubar', 'none')

%-----------------%
%-FILE
m_file = uimenu(opt.h.main, 'label', 'File');
uimenu(m_file, 'label', 'New Dataset', 'call', @cb_newinfo);
uimenu(m_file, 'label', 'Open Dataset', 'call', @cb_openinfo);
uimenu(m_file, 'label', 'Open OPT', 'sep', 'on', 'call', @cb_openopt);
uimenu(m_file, 'label', 'Save OPT', 'call', @cb_saveopt);
%-----------------%

%-----------------%
%-SCORE
m_score = uimenu(opt.h.main, 'label', 'Sleep Score', 'enable', 'off');
uimenu(m_score, 'label', 'Rater', 'tag', 'uimenu_rater', 'enable', 'off')
uimenu(m_score, 'label', 'New Rater', 'sep', 'on', 'call', @cb_rater)
uimenu(m_score, 'label', 'Rename Rater', 'enable', 'off', 'call', @cb_rater)
uimenu(m_score, 'label', 'Copy Current Score', 'enable', 'off', 'call', @cb_rater)
uimenu(m_score, 'label', 'Delete Current Score', 'enable', 'off', 'call', @cb_rater)
uimenu(m_score, 'label', 'Import Score from FASST', 'call', @cb_rater)
%-----------------%

%-----------------%
%-CHAN SELECTION
m_chan = uimenu(opt.h.main, 'label', 'Channel Selection', 'enable', 'off');
for i = 1:numel(opt.changrp)
  uimenu(m_chan, 'label', opt.changrp(i).chantype, 'call', @cb_selchan);
end
%-----------------%

%-----------------%
%-FILTER
m_filt = uimenu(opt.h.main, 'label', 'Filter', 'enable', 'off');
for i = 1:numel(opt.changrp)
  uimenu(m_filt, 'label', opt.changrp(i).chantype, 'call', @cb_filt);
end
%-----------------%

%-----------------%
%-REFERENCE
m_ref = uimenu(opt.h.main, 'label', 'Reference', 'enable', 'off');
for i = 1:numel(opt.changrp)
  uimenu(m_ref, 'label', opt.changrp(i).chantype, 'call', @cb_ref);
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-read the data if present in info
setappdata(0, 'opt', opt)

if nargin > 0 && isfield(info, 'dataset') 
  
  info = prepare_info(info);
  
  save_info()
  setappdata(0, 'info', info)
  
  prepare_info_opt()
  cb_readplotdata()
  
end
%-------------------------------------%
%---------------------------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
%-------------------------------------%
%-callback: save opt
function cb_openinfo(h0, eventdata)

save_info() % save previous info

%-----------------%
%-read OPT file
[filename pathname] = uigetfile({'*.mat', 'Dataset File (*.m, *.mat)'}, 'Select Dataset File');
if ~filename; return; end

info.infofile = [pathname filename];
info = prepare_info(info);
%-----------------%

%-----------------%
%-read and plot data
save_info()
setappdata(0, 'info', info)

prepare_info_opt()
cb_readplotdata()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: load opt
function cb_openopt(h0, eventdata)

opt = getappdata(0, 'opt');

%-----------------%
%-read OPT file
[filename pathname] = uigetfile({'*.mat;*.m', 'Option file (*.m, *.mat)'}, 'Select OPT file');
if ~filename; return; end
opt = prepare_opt([pathname filename], opt);
%-----------------%

%-----------------%
%-read and plot data
setappdata(0, 'opt', opt)

prepare_info_opt()
cb_readplotdata()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: load opt
function cb_saveopt(h0, eventdata) % OK

%-----------------%
%-get current opt and remove handles
opt = getappdata(0, 'opt');
h = opt.h;
axis = opt.axis;
opt = rmfield(opt, {'h' 'axis'});
%-----------------%

%-----------------%
%-file to save
[filename pathname] = uiputfile({'*.mat', 'Option file (*.mat)'}, 'Select OPT file');
if ~filename; return; end
opt.optfile = [pathname filename];
%-----------------%

%-----------------%
%-save and update info
save([pathname filename], 'opt')

opt.h = h;
opt.axis = axis;
setappdata(0, 'opt', opt)
set(findobj('tag', 'name_opt'), 'str', ['OPT: ' filename]) 
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_selchan(h0, eventdata)

chantype = get(h0, 'label');

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

%-------%
%-don't show labels belonging to another chantype
nolabel = arrayfun(@(x) x.chan, opt.changrp(~changrp), 'uni', 0);
nolabel = [nolabel{:}];
[~, ilabel] = setdiff(info.label, nolabel);
label = info.label(sort(ilabel));
%-------%

[~, chanindx] = intersect(label, opt.changrp(changrp).chan);
chanindx = select_channel_list(label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).chan = label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_ref(h0, eventdata)

chantype = get(h0, 'label');

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(info.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(info.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = info.label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: filter information
function cb_filt(h0, eventdata)

chantype = get(h0, 'label');

opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});
Fhp = opt.changrp(changrp).Fhp;
Flp = opt.changrp(changrp).Flp;

%-----------------%
%-popup
prompt = {'High-Pass Filter (Hz)' 'Low-Pass Filter (Hz)'};
name = ['Filter for ' chantype];
numlines = 1;
defaultanswer = {sprintf(' %1g', Fhp) sprintf(' %1g', Flp)};
answer = inputdlg(prompt, name, numlines, defaultanswer);

if ~isempty(answer) % cancel button
  
  %-------%
  %-highpass filter
  if ~isempty(answer{1})
    Fhp = textscan(answer{1}, '%f');
    opt.changrp(changrp).Fhp = Fhp{1};
  else
    opt.changrp(changrp).Fhp = [];
  end
  %-------%
  
  %-------%
  %-lowpass filter
  if ~isempty(answer{2})
    Flp = textscan(answer{2}, '%f');
    opt.changrp(changrp).Flp = Flp{1};
  else
    opt.changrp(changrp).Flp = [];
  end
  %-------%
  
  setappdata(0, 'opt', opt);
  cb_readplotdata()
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: go back
function cb_bb(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = opt.epoch - 1;
setappdata(0, 'opt', opt);

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: go forward
function cb_ff(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = opt.epoch + 1;
setappdata(0, 'opt', opt);

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: change epoch
function cb_epoch(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = str2double(get(h0, 'str'));
setappdata(0, 'opt', opt)

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: smaller scale
function cb_yu(h0, eventdata)

opt = getappdata(0, 'opt');
opt.ylim = opt.ylim / 1.1;
setappdata(0, 'opt', opt);

cb_ylim()
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_yd(h0, eventdata)

opt = getappdata(0, 'opt');
opt.ylim = opt.ylim * 1.1;
setappdata(0, 'opt', opt);

cb_ylim()
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: adjust scale
function cb_ylim(h0, eventdata)

opt = getappdata(0, 'opt');

if nargin > 0
  
  opt.ylim = [-1 1] * str2double(get(h0, 'str'));
  setappdata(0, 'opt', opt);
  cb_plotdata()
  
else
  set(findobj('tag', 'ylimval'), 'str', num2str(opt.ylim(2)));
  
end
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid75(h0, eventdata)

opt = getappdata(0, 'opt');
opt.grid75 = ~opt.grid75;
setappdata(0, 'opt', opt);

set(findobj('str', '75uV'), 'val', opt.grid75)
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid1s(h0, eventdata)

opt = getappdata(0, 'opt');
opt.grid1s = ~opt.grid1s;
setappdata(0, 'opt', opt);

set(findobj('str', '1s'), 'val', opt.grid1s)
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: close figure
function cb_closemain(h0, eventdata)

save_info()
setappdata(0, 'info', []) % clean up info
setappdata(0, 'opt', []) % clean up opt
setappdata(0, 'hdr', [])
setappdata(0, 'dat', [])
setappdata(0, 'tmp', [])
delete(h0);
%-------------------------------------%
%---------------------------------------------------------%