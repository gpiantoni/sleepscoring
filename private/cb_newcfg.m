function cb_newcfg(h0, eventdata)
%CB_NEWCFG

%-------------------------------------%
%-popup
h_input = figure;
set(h_input, 'tag', 'newcfg', 'Menubar', 'none')

set(h_input, 'pos', get(h_input, 'pos') .* [1 1 1 .5]) % half height

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .8 .9 .1], 'str', 'Dataset to read');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'datasetdir', ...
  'pos', [.05 .6 .9 .2], 'str', '(click to select)', ...
  'call', @cb_uigetdir); % TODO: or file

uicontrol(h_input, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .4 .9 .1], 'str', 'Save CFG in');

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', 'tag', 'cfgfile', ...
  'pos', [.05 .2 .9 .2], 'str', '(click to select)', ...
  'call', @cb_uiputfile);

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.75 .05 .1 .1], 'str', 'OK', ...
  'call', @cb_ok);

uicontrol(h_input, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.85 .05 .1 .1], 'str', 'cancel', ...
  'call', @cb_cancel);
%-------------------------------------%

uiwait(h_input)

%-------------------------------------%
%-callback
%-----------------%
%-cb_uigetdir
function cb_uigetdir(h0, eventdata)
dirname = uigetdir;

if dirname
  set(h0, 'str', dirname)
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

cfg = [];
cfg.dataset = get(findobj('tag', 'datasetdir'), 'str');
cfg.cfgfile = get(findobj('tag', 'cfgfile'), 'str');

if ~strcmp(cfg.dataset, '(click to select)') || ...
    ~strcmp(cfg.cfgfile, '(click to select)')
  
  cfg = prepare_info(cfg);
  delete(findobj('tag', 'newcfg'))
  
  %-------%
  %-init
  savecfg()
  setappdata(0, 'cfg', cfg)
  sleepscoring_init()
  cb_readplotdata()
  %-------%
  
end
%-----------------%

%-----------------%
%-cb_cancel
function cb_cancel(h0, eventdat)

delete(findobj('tag', 'newcfg'))
%-----------------%
%-------------------------------------%
