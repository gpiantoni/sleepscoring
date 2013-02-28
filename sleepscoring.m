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
%                     If you specify a .infofile, it'll save the INFO
%                     variable in the file .infofile.
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
  opt = [fileparts(mfilename('fullpath')) filesep 'preference' filesep 'opt_ssmd_egi.m']; % default OPT
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
  'pos', [.05 .75 .25 .1], 'str', '<<', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_bb);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .75 .30 .1], 'str', '', 'tag', 'epochnumber','KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_epoch); 
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .75 .25 .1], 'str', '>>', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_ff);
%-------%

%-------%
%-scaling
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .6 .25 .1], 'str', '+', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_yu);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .6 .30 .1], 'str', num2str(opt.ylim(2)), 'tag', 'ylimval', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_ylim);
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .6 .25 .1], 'str', '-', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_yd);
%-------%

%-------%
%-grid
uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.05 .45 .4 .1], 'str', '75uV', 'KeyPressFcn', @cb_shortcuts, ...
  'val', opt.grid75, 'call', @cb_grid75);

uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.55 .45 .4 .1], 'str', '1s', 'KeyPressFcn', @cb_shortcuts, ...
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
uimenu(m_score, 'label', 'Merge Scores', 'enable', 'off', 'call', @cb_rater)
uimenu(m_score, 'label', 'Delete Current Score', 'enable', 'off', 'call', @cb_rater)
uimenu(m_score, 'label', 'Import Score from FASST', 'call', @cb_rater)
uimenu(m_score, 'label', 'Score Statistics', 'sep', 'on', 'call', @cb_statistics)
%-----------------%

uimenu(opt.h.main, 'label', 'Channel Selection', 'enable', 'off');
uimenu(opt.h.main, 'label', 'Filter', 'enable', 'off');
uimenu(opt.h.main, 'label', 'Reference', 'enable', 'off');
%-------------------------------------%

%-------------------------------------%
%-read the data if present in info
setappdata(0, 'opt', opt)

if nargin > 0 && ischar(info)
  infofile = info;
  info = [];
  info.infofile = infofile;
end

if nargin > 0 && (isfield(info, 'dataset') || isfield(info, 'infofile'))
  
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
%--------%
%-move to directory with opt
info = getappdata(0, 'info');
wd = pwd;
if isfield(info, 'infofile')
  cd(fileparts(info.infofile))
end
info = [];
%--------%

%--------%
%-get files
[filename pathname] = uigetfile({'*.mat', 'Dataset File (*.m, *.mat)'}, 'Select Dataset File');
cd(wd)
if ~filename; return; end
%--------%

%--------%
%-log that the file was closed
prepare_log('closeinfo')
save_info()
%--------%
%-----------------%

%-----------------%
%-read and plot new info
info.infofile = [pathname filename];
info = prepare_info(info);
setappdata(0, 'info', info)
save_info()
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
wd = pwd;
cd(fileparts(opt.optfile))
[filename pathname] = uigetfile({'*.mat;*.m', 'Option file (*.m, *.mat)'}, 'Select OPT file');
cd(wd)
if ~filename; return; end
opt = prepare_opt([pathname filename], opt);
%-----------------%

%-----------------%
%-read and plot data
setappdata(0, 'opt', opt)

if ~isempty(getappdata(0, 'info'))
  prepare_info_opt()
  cb_readplotdata()
end
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
%--------%
%-move to directory with opt
wd = pwd;
cd(fileparts(opt.optfile))
%--------%

[filename pathname] = uiputfile({'*.mat', 'Option file (*.mat)'}, 'Select OPT file');
cd(wd)

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
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_yd(h0, eventdata)

opt = getappdata(0, 'opt');
opt.ylim = opt.ylim * 1.1;
setappdata(0, 'opt', opt);

cb_ylim()
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: adjust scale
function cb_ylim(h0, eventdata)

opt = getappdata(0, 'opt');

if nargin > 0
  
  opt.ylim = [-1 1] * str2double(get(h0, 'str'));
  setappdata(0, 'opt', opt);
  cb_plotdata(h0)
  
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
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid1s(h0, eventdata)

opt = getappdata(0, 'opt');
opt.grid1s = ~opt.grid1s;
setappdata(0, 'opt', opt);

set(findobj('str', '1s'), 'val', opt.grid1s)
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: close figure
function cb_closemain(h0, eventdata)

prepare_log('closeinfo')
save_info()
setappdata(0, 'info', []) % clean up info
setappdata(0, 'opt', []) % clean up opt
setappdata(0, 'hdr', [])
setappdata(0, 'dat', [])
setappdata(0, 'tmp', [])
delete(h0);
%-------------------------------------%
%---------------------------------------------------------%