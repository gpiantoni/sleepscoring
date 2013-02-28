function cb_plotdata(h0, eventdata)
%CB_PLOTDATA callback that only plots data
%
% Called by
%  - cb_readplotdata

%-----------------%
%-read info
info = getappdata(0, 'info');
opt = getappdata(0, 'opt');
dat = getappdata(0, 'dat');
%-----------------%

%-------------------------------------%
%-main window
%-----------------%
%-plot data
delete(findobj('tag', 'a_dat'))
axes('parent', opt.h.data, 'tag', 'a_dat');

delete(findobj('tag', 'marker'))
plot_marker()

plot_data(info, opt, dat);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-hypnogram
delete(findobj('tag', 'a_hypno'))
axes('parent', findobj('tag', 'p_hypno'), 'tag', 'a_hypno');

%-------%
%-info to hypnogram
opt.beginrec = info.beginrec;
opt.wndw = info.score(info.rater).wndw;
%-------%

plot_hypno(opt, info.score(info.rater))

score_popup(info, opt)
%-------------------------------------%

drawnow
