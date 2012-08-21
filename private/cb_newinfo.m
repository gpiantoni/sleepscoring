function cb_newinfo(h0, eventdata)
%CB_NEWINFO create GUI to enter information for a new dataset

%-------------------------------------%
%-new figure
h_input = figure;
set(h_input, 'tag', 'newinfo', 'Menubar', 'none')

set(h_input, 'pos', get(h_input, 'pos') .* [1 1 1 .5]) % half height

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .8 .4 .1], 'str', 'Directory to read (f.e. MFF)');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'datasetdir', ...
  'pos', [.05 .6 .4 .2], 'str', '(click to select)', ...
  'call', @cb_uigetdir);

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.55 .8 .4 .1], 'str', 'File to read (f.e. FASST)');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'datasetfile', ...
  'pos', [.55 .6 .4 .2], 'str', '(click to select)', ...
  'call', @cb_uigetfile);

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .4 .9 .1], 'str', 'Save info in');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'infofile', ...
  'pos', [.05 .2 .9 .2], 'str', '(click to select)', ...
  'call', @cb_uiputfile);

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
%-cb_ok
function cb_ok(h0, eventdata)

info = [];
info.dataset = get(findobj('tag', 'dataset2read'), 'str');
info.infofile = get(findobj('tag', 'infofile'), 'str');

if ~isempty(info.dataset) && ...
    ~strcmp(info.infofile, '(click to select)')
  
  delete(findobj('tag', 'newinfo'))
  
  info = prepare_info(info);
  
  %-------%
  %-init
  save_info()
  setappdata(0, 'info', info)
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
