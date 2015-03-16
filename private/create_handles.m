function h = create_handles(opt)
%CREATE_HANDLES create new figure, with all the handles
%
% OPT:
%  .optfile: name of the file, to add in panel
%  .ylim: default size of the height
%  .grid75: +- 75 uV grid
%  .grid1s: one second grid
%
%PANEL POSITION: horizontal dimensions
%  .marg.l: left margin
%  .width.l: width of objects on the left
%  .marg.r: margin between left and right
%  .width.r: width of objects on the right
%
%PANEL POSITION: vertical dimensions
%  .marg.d: margin below
%  .height.d: height of objects below
%  .marg.u: margin between up and down
%  .height.u: height of objects above
%
% Called by:
%  - sleepscoring

%-------------------------------------%
%-New figure
h.main = figure;
set(h.main, 'tag', 'sleepscoring', 'name', 'Sleep Scoring', 'numbertitle', 'off', ...
  'closerequestfcn', @cb_closemain)

set(h.main, 'KeyPressFcn', @cb_shortcuts)
%-------------------------------------%

%-------------------------------------%
%-PANELS
%-----------------%
%-create main panels
h.panel.data.h = uipanel('Title', 'Sleep Data', 'FontSize', 12, ...
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.u opt.width.l opt.height.u]);

h.panel.hypno.h = uipanel('Title', 'Recording', 'FontSize', 12, 'tag', 'p_hypno',...
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.d opt.width.l opt.height.d]);

h.panel.info.h = uipanel('Title', 'Information', 'FontSize', 12, ...
  'Position', [opt.marg.r opt.marg.u opt.width.r opt.height.u]);

h.panel.fft.h = uipanel('Title', 'PowerSpectrum', 'FontSize', 12, 'tag', 'p_fft', ...
  'BackgroundColor','white', ...
  'Position', [opt.marg.r opt.marg.d opt.width.r opt.height.d]);

%-------%
%-create axes
h.axis.data = axes('parent', h.panel.data.h, 'vis', 'off');
h.axis.hypno = axes('parent', h.panel.hypno.h, 'vis', 'off');
h.axis.fft = axes('parent', h.panel.fft.h, 'vis', 'off');
%-------%
%-----------------%

%-----------------%
%-create button and various items in the information panel
%-------%
%-info
h.panel.info.infoname = uicontrol(h.panel.info.h, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .95 .9 .05], 'str', 'Dataset:');
[~, optname] = fileparts(opt.optfile);
h.panel.info.optname = uicontrol(h.panel.info.h, 'sty', 'text', 'uni', 'norm', ...
  'pos', [.05 .9 .9 .05], 'str', ['OPT: ' optname]);
%-------%

%-------%
%-change epochs
uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .75 .25 .1], 'str', '<<', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_bb);
h.panel.info.epoch = uicontrol(h.panel.info.h, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .75 .30 .1], 'str', '', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_epoch); 
uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .75 .25 .1], 'str', '>>', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_ff);
%-------%

%-------%
%-scaling
uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .6 .25 .1], 'str', '+', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_yu);
h.panel.info.ylimval = uicontrol(h.panel.info.h, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .6 .30 .1], 'str', num2str(opt.ylim(2)), 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_ylim);
uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .6 .25 .1], 'str', '-', 'KeyPressFcn', @cb_shortcuts, ...
  'call', @cb_yd);
%-------%

%-------%
%-grid
h.panel.info.uV75 = uicontrol(h.panel.info.h, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.05 .45 .4 .1], 'str', '75uV', 'KeyPressFcn', @cb_shortcuts, ...
  'val', opt.grid75, 'call', @cb_grid75);

h.panel.info.s1 = uicontrol(h.panel.info.h, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.55 .45 .4 .1], 'str', '1s', 'KeyPressFcn', @cb_shortcuts, ...
  'val', opt.grid1s, 'call', @cb_grid1s);
%-------%

%-------%
%-score and marker popup
h.panel.info.popupscore = uicontrol(h.panel.info.h, 'sty', 'popup', 'uni', 'norm', ...
  'pos', [.05 .3 .9 .1], 'str', {''}, 'val', 1, ... % 'str' and 'val' have default values
 'vis', 'off', 'call', @cb_score);

h.panel.info.marker.popup = uicontrol(h.panel.info.h, 'sty', 'popup', 'uni', 'norm', ...
  'pos', [.05 .15 .9 .1], 'str', {''}, 'val', 1, ... % 'str' and 'val' have default values
  'vis', 'off', 'call', @cb_marker); 

h.panel.info.marker.bb = uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .05 .25 .1], 'str', '<<', 'vis', 'off', 'call', @cb_mbb);
h.panel.info.marker.ff = uicontrol(h.panel.info.h, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .05 .25 .1], 'str', '>>', 'vis', 'off', 'call', @cb_mff);
%-------%
%-----------------%  
%-------------------------------------%

%-------------------------------------%
%-Menu bar
set(h.main, 'Menubar', 'none')

%-----------------%
%-FILE
h.menu.file.h = uimenu(h.main, 'label', 'File');
uimenu(h.menu.file.h, 'label', 'New Dataset', 'call', @cb_newinfo);
uimenu(h.menu.file.h, 'label', 'Open Dataset', 'call', @cb_openinfo);
uimenu(h.menu.file.h, 'label', 'Open OPT', 'sep', 'on', 'call', @cb_openopt);
uimenu(h.menu.file.h, 'label', 'Save OPT', 'call', @cb_saveopt);
%-----------------%

%-----------------%
%-EVENT
h.menu.event.h = uimenu(h.main, 'label', 'Events', 'enable', 'off');
h.menu.event.show = uimenu(h.menu.event.h, 'label', 'Show', 'checked', 'off', 'call', @cb_event_show);
%-----------------%

%-----------------%
%-SCORE
h.menu.score.h = uimenu(h.main, 'label', 'Sleep Score', 'enable', 'off');
h.menu.score.rater = uimenu(h.menu.score.h, 'label', 'Rater', 'enable', 'off');
h.menu.score.new = uimenu(h.menu.score.h, 'label', 'New Rater', 'sep', 'on', 'call', @cb_rater);
h.menu.score.rename = uimenu(h.menu.score.h, 'label', 'Rename Rater', 'call', @cb_rater, 'enable', 'off');
h.menu.score.copy = uimenu(h.menu.score.h, 'label', 'Copy Current Score', 'call', @cb_rater, 'enable', 'off');
h.menu.score.merge = uimenu(h.menu.score.h, 'label', 'Merge Scores', 'call', @cb_rater, 'enable', 'off');
h.menu.score.fasst = uimenu(h.menu.score.h, 'label', 'Import Score from FASST', 'call', @cb_rater);
h.menu.score.delete = uimenu(h.menu.score.h, 'label', 'Delete Current Score', 'call', @cb_rater, 'enable', 'off');
%-----------------%

%-----------------%
%-REVIEW
h.menu.rev.h = uimenu(h.main, 'label', 'Review', 'enable', 'off');
h.menu.rev.statistics = uimenu(h.menu.rev.h, 'label', 'Score Statistics', 'call', @cb_statistics);
h.menu.rev.statistics_file = uimenu(h.menu.rev.h, 'label', 'Score Statistics (to file) ...', 'call', @cb_statistics);
h.menu.rev.score = uimenu(h.menu.rev.h, 'label', 'Score', 'sep', 'on', 'call', @cb_scorefile);
h.menu.rev.score_file = uimenu(h.menu.rev.h, 'label', 'Score (to file) ...', 'call', @cb_scorefile);
h.menu.rev.marker = uimenu(h.menu.rev.h, 'label', 'Marker Times', 'sep', 'on', 'call', @cb_markertime);
%-----------------%

h.menu.chan.h = uimenu(h.main, 'label', 'Channel Selection', 'enable', 'off');
h.menu.filt.h = uimenu(h.main, 'label', 'Filter', 'enable', 'off');
h.menu.ref.h = uimenu(h.main, 'label', 'Reference', 'enable', 'off');
%-------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
%-------------------------------------%
%-callback: save opt
function cb_openinfo(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');

%-----------------%
%-open directory of old info
%--------%
%-move to directory with info
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
%-log that the previous file was closed
info = prepare_log(info, 'closeinfo');
save_info(info) % save previous info
%--------%
%-----------------%

%-----------------%
%-read and plot new info
info.infofile = [pathname filename];
[info hdr] = prepare_info(info);
save_info(info)
setappdata(h0, 'info', info)
setappdata(h0, 'hdr', hdr)

prepare_info_opt(h0)
cb_readplotdata(h0)
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: load opt
function cb_openopt(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');

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
setappdata(h0, 'opt', opt)

if ~isempty(getappdata(h0, 'info'))
  prepare_info_opt(h0, 1)
  cb_readplotdata(h0)
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: load opt
function cb_saveopt(h, eventdata) % OK

%-----------------%
%-get current opt and remove handles
h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');

h = opt.h;
opt = rmfield(opt, 'h');
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
setappdata(h0, 'opt', opt)
set(opt.h.panel.info.optname, 'str', ['OPT: ' filename]) 
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: change event checked status
function cb_event_show(h, eventdata)

h0 = get_parent_fig(h);

opt = getappdata(h0, 'opt');
if strcmp(get(h, 'checked'), 'on')
  set(h, 'checked', 'off')
  opt.event.show = false;

else
  set(h, 'checked', 'on')
  opt.event.show = true;
    
end
setappdata(h0, 'opt', opt);

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: go back
function cb_bb(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.epoch = opt.epoch - 1;
setappdata(h0, 'opt', opt);

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: go forward
function cb_ff(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.epoch = opt.epoch + 1;
setappdata(h0, 'opt', opt);

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: change epoch
function cb_epoch(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.epoch = str2double(get(h, 'str'));
setappdata(h0, 'opt', opt)

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: smaller scale
function cb_yu(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.ylim = opt.ylim / 1.1;
setappdata(h0, 'opt', opt);

set(opt.h.panel.info.ylimval, 'str', num2str(opt.ylim(2)));
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_yd(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.ylim = opt.ylim * 1.1;
setappdata(h0, 'opt', opt);

set(opt.h.panel.info.ylimval, 'str', num2str(opt.ylim(2)));
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: adjust scale
function cb_ylim(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
 
opt.ylim = [-1 1] * str2double(get(h, 'str'));
setappdata(h0, 'opt', opt);
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid75(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.grid75 = ~opt.grid75;
setappdata(h0, 'opt', opt);

set(opt.h.panel.info.uV75, 'val', opt.grid75)
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid1s(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.grid1s = ~opt.grid1s;
setappdata(h0, 'opt', opt);

set(opt.h.panel.info.s1, 'val', opt.grid1s)
cb_plotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: close figure
function cb_closemain(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
info = prepare_log(info, 'closeinfo');
save_info(info)

delete(h0);
%-------------------------------------%

%-------------------------------------%
%-callback: replot figure after changing score
function cb_score(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

i_score = get(h, 'val');
info.score(info.rater).stage{opt.epoch} = opt.stage(i_score).label;
save_info(info)
setappdata(h0, 'info', info)

opt.epoch = opt.epoch + 1;
setappdata(h0, 'opt', opt)

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: change value for marker
function cb_marker(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');
opt.marker.i = get(h, 'val');

enable_marker(info, opt)

setappdata(h0, 'opt', opt)
%-------------------------------------%

%-------------------------------------%
%-callback: move to previous epoch with marker
function cb_mbb(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

epoch = get_epoch(info, opt);
% following epoch with markers
opt.epoch = epoch(find(epoch < opt.epoch, 1, 'last')); 
if isempty(opt.epoch); return; end

enable_marker(info, opt)

setappdata(h0, 'opt', opt);

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
%-callback: move to next epoch with marker
function cb_mff(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

epoch = get_epoch(info, opt);
% following epoch with markers
opt.epoch = epoch(find(epoch > opt.epoch, 1));
if isempty(opt.epoch); return; end

enable_marker(info, opt)

setappdata(h0, 'opt', opt);

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
function cb_scorefile(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');

if strcmp(get(h, 'label'), 'Score (to file) ...')
  
  [filename, pathname] = uiputfile('*.csv', 'Save Score of Current Rater to CSV File');
  if filename
    csvfile = fullfile(pathname, filename);
    scorewriting(info, csvfile)
  end
  
else
  scorewriting(info)
  
end
%-------------------------------------%
%---------------------------------------------------------%
