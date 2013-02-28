function cb_newinfo(h, eventdata)
%CB_NEWINFO create GUI to enter information for a new dataset
%
% Called by
%  - sleepscoring

%-------------------------------------%
%-new figure
h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');

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
function cb_uigetdir(h, eventdata)
dirname = uigetdir;

if dirname
  
  h0 = get_parent_fig(h);
  set(h, 'str', dirname)
  set(findobj(h0, 'tag', 'datasetfile'), 'enable', 'off')
  set(findobj(h0, 'tag', 'datasetdir'), 'tag', 'dataset2read')
  
end
%-----------------%

%-----------------%
%-cb_uigetfile
function cb_uigetfile(h, eventdata)
[filename pathname] = uigetfile;

if filename
  
  h0 = get_parent_fig(h);
  set(h, 'str', [pathname filename])
  set(findobj(h0, 'tag', 'datasetdir'), 'enable', 'off')
  set(findobj(h0, 'tag', 'datasetfile'), 'tag', 'dataset2read')
  
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
function cb_ok(h, eventdata)

h0 = get_parent_fig(h);

info = [];
info.dataset = get(findobj(h0, 'tag', 'dataset2read'), 'str');
info.infofile = get(findobj(h0, 'tag', 'infofile'), 'str');
optfile = get(findobj(h0, 'tag', 'optfile'), 'str');

if ~isempty(info.dataset) && ...
    ~strcmp(info.infofile, '(click to select)')
  
  delete(findobj(h0, 'tag', 'newinfo'))
  drawnow
  
  %-------%
  %-init
  info = prepare_info(info);
  save_info(info)
  setappdata(h0, 'info', info)
    
  opt_old = getappdata(h0, 'opt'); % necessary for figure handles
  opt = prepare_opt(optfile, opt_old);
  setappdata(h0, 'opt', opt)

  prepare_info_opt(h0)
  cb_readplotdata(h0)
  %-------%
  
end
%-----------------%

%-----------------%
%-cb_cancel
function cb_cancel(h, eventdat)

h0 = get_parent_fig(h);
delete(findobj(h0, 'tag', 'newinfo'))
%-----------------%
%-------------------------------------%
