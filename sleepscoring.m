function sleepscoring(opt, cfg)
%SLEEPSCORING do sleep scoring on EGI data
% This function takes one optional CFG argument. If no input, go to
% "File" >> "Load MFF" and select the .mff folder with the sleep data.
% To start a new sleep score, go to "Sleep Score" >> "New Score" and add
% the relevant information.
% 
% Two optional arguments: CFG and OPT
%   .dataset: the absolute path to the MFF file
%   .hdr: the header of the MFF file (use ft_read_header). If .hdr is not
%         present, it'll be read from .dataset
%
%   .default.channame: if you want to rename some channels, you can use
%                      this function. By default, it uses CHANNAME. You can
%                      use any other function, based on channame.m
%
%   OPT: all the optional information, for example the default
%                 channels and visualization properties. By default, it
%                 uses OPT_DEFAULT. If you want to edit the optional
%                 information, create a new file based on "opt_default.m"
%                 and change the parameter. Then .default.opt should
%                 contain the name of the new file.
%  
% SLEEPSCORING can only run in one window at the time. If you want to run
% two sessions at the same time, open a new Matlab.
%    
% Difference between CFG and OPT: CFG is dataset specific, OPT is general
% OPT is necessary and always loaded, while CFG can be created on the fly
% CFG is automatically saved, OPT only if you click on save

%TODO:
% - multiple windows
% - automatic detection of SW and spindles
% - automatic scoring
% - when sleep scoring, enter beginning of sleep
% - hObject,h -> h0
% - notes for each epoch
% - score names does not check on
% - make dat1 with following epoch to preload following epoch

%---------------------------------------------------------%
%-GUI FUNCTION
%---------------------------------------------------------%

%-------------------------------------%
%-CHECK INPUT
ftdir = which('ft_read_header');
if strcmp(ftdir, '')
  error('Please add fieldtrip folder and execute ''ft_defaults''')
end

addpath([fileparts(mfilename('fullpath')) filesep 'preference'])

if nargin == 0
  opt = 'opt_default.m'; % default OPT (TODO: maybe absolute path?)
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
set(opt.h.main, 'tag', 'sleepscoring', ...
  'closerequestfcn', @cb_closemain)

set(opt.h.main, 'KeyPressFcn', @cb_shortcuts)
%-------------------------------------%

%-------------------------------------%
%-PANELS
%-----------------%
%-create main panels
opt.h.data = uipanel('Title', 'Sleep Data', 'FontSize', 12, 'tag', 'p_data', ... % rename with name of subject
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.u opt.width.l opt.height.u]);

opt.h.hypno = uipanel('Title', 'Hypnogram', 'FontSize', 12, 'tag', 'p_hypno',...
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
  'pos', [.05 .95 .9 .05], 'str', 'Dataset:', 'tag', 'name_cfg');
uicontrol(opt.h.info, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .9 .9 .05], 'str', ['OPT: ' opt.optname], 'tag', 'name_opt');
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
uimenu(m_file, 'label', 'New Dataset', 'call', @cb_newcfg);
uimenu(m_file, 'label', 'Open Dataset', 'call', @cb_opencfg);
uimenu(m_file, 'label', 'Open OPT', 'sep', 'on', 'call', @cb_openopt);
uimenu(m_file, 'label', 'Save OPT', 'call', @cb_saveopt);
%-----------------%

%-----------------%
%-SCORE
m_score = uimenu(opt.h.main, 'label', 'Sleep Score');
uimenu(m_score, 'label', 'New Score', 'call', @cb_newrater)
uimenu(m_score, 'label', 'Load Score', 'call', @cb_loadscore)
uimenu(m_score, 'label', 'Import Score from FASST', 'call', @cb_importscore)
uimenu(m_score, 'label', 'Rater', 'Sep', 'on', 'tag', 'uimenu_rater', 'enable', 'off')
uimenu(m_score, 'label', 'New Rater', 'call', @cb_newrater)
%-----------------%

%-----------------%
%-CHAN SELECTION
m_chan = uimenu(opt.h.main, 'label', 'Channel Selection');
for i = 1:numel(opt.changrp)
  uimenu(m_chan, 'label', opt.changrp(i).chantype, 'call', @cb_selchan);
end
%-----------------%

%-----------------%
%-FILTER
m_filt = uimenu(opt.h.main, 'label', 'Filter');
for i = 1:numel(opt.changrp)
  uimenu(m_filt, 'label', opt.changrp(i).chantype, 'call', @cb_filt);
end
%-----------------%

%-----------------%
%-REFERENCE
m_ref = uimenu(opt.h.main, 'label', 'Reference');
for i = 1:numel(opt.changrp)
  uimenu(m_ref, 'label', opt.changrp(i).chantype, 'call', @cb_ref);
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-read the data if present in cfg
setappdata(0, 'opt', opt)

if nargin > 1 && isfield(cfg, 'dataset') 
  
  cfg = prepare_info(cfg);
  
  savecfg()
  setappdata(0, 'cfg', cfg)
  
  sleepscoring_init()
  cb_readplotdata()
  
end
%-------------------------------------%
%---------------------------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%

%-------------------------------------%
%-callback: save opt
function cb_opencfg(h0, eventdata)

savecfg() % save previous cfg

%-----------------%
%-read OPT file
[filename pathname] = uigetfile({'*.mat', 'Dataset File (*.m, *.mat)'}, 'Select Dataset File');
if ~filename; return; end

cfg.cfgfile = [pathname filename];
cfg = prepare_info(cfg);
%-----------------%

%-----------------%
%-read and plot data
savecfg()
setappdata(0, 'cfg', cfg)

sleepscoring_init()
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

sleepscoring_init()
cb_readplotdata()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_selchan(h0, eventdata)

chantype = get(h0, 'label');

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

%-------%
%-don't show labels belonging to another chantype
nolabel = arrayfun(@(x) x.chan, opt.changrp(~changrp), 'uni', 0);
nolabel = [nolabel{:}];
[~, ilabel] = setdiff(cfg.label, nolabel);
label = cfg.label(sort(ilabel));
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

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(cfg.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(cfg.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = cfg.label(chanindx)';

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
%-callback: load sleep score
function cb_loadscore(h0, eventdata)

%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_importscore(h0, eventdata)
%TODO: indicate that this will overwrite current score
%TODO: check that the length is consistent

[filename, pathname] = uigetfile('*.mat', 'Select FASST file');
warning off % class to struct warning
load([pathname filename], 'D')
warning on

cfg = getappdata(0, 'cfg');
if isfield(D.other, 'CRC') && isfield(D.other.CRC, 'score')
  cfg.score = D.other.CRC.score;

  cfg.rater = 1;
  setappdata(0, 'cfg', cfg)
  update_rater()
end
%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_newrater(h0, eventdata)

%-----------------%
cfg = getappdata(0, 'cfg');

if strcmp(get(h0, 'label'), 'New Score')
  ConfirmDel = questdlg('Are you sure that you want to delete the current scoring?', ...
    'Replace Score', ...
    'Yes', 'No', 'Yes');
  if strcmp(ConfirmDel, 'No'); return; end
  
  cfg.score = [];
end

if isempty(cfg.score)
  newrater = 1;
else
  newrater = size(cfg.score,2) + 1;
end
%-----------------%

%-----------------%
%-prompt
prompt = {'Rater Name' 'Window Duration'};
name = 'Sleep Score Information';
defaultanswer = {'' '30'};
answer = inputdlg(prompt, name, 1, defaultanswer);

wndw = textscan(answer{2}, '%f');
wndw = wndw{1};
%-----------------%

%-----------------%
%-update cfg
cfg.rater = newrater;
setappdata(0, 'cfg', cfg)

sleepscoring_init()
update_rater()
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

savecfg()
setappdata(0, 'cfg', []) % clean up cfg
setappdata(0, 'opt', []) % clean up opt
delete(h0);
%-------------------------------------%
%---------------------------------------------------------%