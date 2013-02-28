function cb_newinfo(h0, eventdata)
%CB_NEWINFO create GUI to enter information for a new dataset
%
% Called by
%  - sleepscoring

%-------------------------------------%
%-new figure
opt = getappdata(0, 'opt');

h_input = figure;
set(h_input, 'tag', 'newinfo', 'Menubar', 'none', 'name', 'New Dataset')

set(h_input, 'pos', get(h_input, 'pos') .* [1 1 1 .7]) % half height

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .8  .4 .1], 'str', 'Directory to read (f.e. MFF)');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'datasetdir', ...
  'pos', [.05 .7 .4 .15], 'str', '(click to select)', ...
  'call', @cb_uigetdir);

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.55 .8  .4 .1], 'str', 'File to read (f.e. FASST)');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'datasetfile', ...
  'pos', [.55 .7 .4 .15], 'str', '(click to select)', ...
  'call', @cb_uigetfile);

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .55 .9 .1], 'str', 'Save info in');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'infofile', ...
  'pos', [.05 .45 .9 .15], 'str', '(click to select)', ...
  'call', @cb_uiputfile);

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .3  .9 .1], 'str', 'Load option (preference) file:');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'optfile', ...
  'pos', [.05 .2  .9 .15], 'str', opt.optfile, ...
  'call', @cb_uigetopt);

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.75 .05 .1 .1], 'str', 'OK', ...
  'call', @cb_ok);

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.85 .05 .1 .1], 'str', 'cancel', ...
  'call', @cb_cancel);

uiwait(h_input)
%-------------------------------------%

%-------------------------------------%
%-callback
%-----------------%
%-cb_uigetdir
function cb_uigetdir(h0, eventdata)
dirname = uigetdir;

if dirname
  set(h0, 'str', dirname)
  set(findobj('tag', 'datasetfile'), 'enable', 'off')
  set(findobj('tag', 'datasetdir'), 'tag', 'dataset2read')
  
end
%-----------------%

%-----------------%
%-cb_uigetfile
function cb_uigetfile(h0, eventdata)
[filename pathname] = uigetfile;

if filename
  set(h0, 'str', [pathname filename])
  set(findobj('tag', 'datasetdir'), 'enable', 'off')
  set(findobj('tag', 'datasetfile'), 'tag', 'dataset2read')
  
end
%-----------------%

%-----------------%
%-cb_uiputfile
function cb_uiputfile(h0, eventdata)
[filename pathname] = uiputfile;

if filename
  set(h0, 'str', [pathname filename])
end
%-----------------%

%-----------------%
%-cb_uigetopt
function cb_uigetopt(h0, eventdata)

optfile = get(h0, 'str');

wd = pwd;
cd(fileparts(optfile))
[filename pathname] = uigetfile({'*.mat;*.m', 'Option file (*.m, *.mat)'}, 'Select OPT file');
cd(wd)

if filename
  set(h0, 'str', [pathname filename])
end
%-----------------%

%-----------------%
%-cb_ok
function cb_ok(h0, eventdata)

info = [];
info.dataset = get(findobj('tag', 'dataset2read'), 'str');
info.infofile = get(findobj('tag', 'infofile'), 'str');
optfile = get(findobj('tag', 'optfile'), 'str');

if ~isempty(info.dataset) && ...
    ~strcmp(info.infofile, '(click to select)')
  
  delete(findobj('tag', 'newinfo'))
  drawnow
  
  %-------%
  %-init
  info = prepare_info(info);
  setappdata(0, 'info', info)
  save_info()
  
  opt_old = getappdata(0, 'opt'); % necessary for figure handles
  opt = prepare_opt(optfile, opt_old);
  setappdata(0, 'opt', opt)
  prepare_info_opt()
  cb_readplotdata()
  %-------%
  
end
%-----------------%

%-----------------%
%-cb_cancel
function cb_cancel(h0, eventdat)

delete(findobj('tag', 'newinfo'))
%-----------------%
%-------------------------------------%
