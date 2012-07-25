%-------------------------------------%
%-callback: read and replot data
function cb_readplotdata(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
dat = readdata(cfg, opt);
setappdata(0, 'dat', dat);

cb_plotdata
%-------------------------------------%