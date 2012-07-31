function popup_marker(cfg, opt)
%---------------------------------------------------------%
%-MAIN FUNCTION
%---------------------------------------------------------%
opt.i_marker = 1;
uicontrol(opt.h.info, 'sty', 'popup', 'uni', 'norm', ...
  'pos', [.05 .25 .9 .1], 'str', opt.marker, 'val', opt.i_marker, 'tag', 'popupscore', ...
  'call', @cb_marker);

setappdata(0, 'opt', opt)
%---------------------------------------------------------%


%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
function cb_marker(h, eventdata)

opt = getappdata(0, 'opt');
opt.i_marker = get(h, 'val');
setappdata(0, 'opt', opt)
%---------------------------------------------------------%