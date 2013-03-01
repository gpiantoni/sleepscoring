function cb_plotdata(h0)
%CB_PLOTDATA callback that only plots data
%
% Called by
%  - cb_currentpoint
%  - cb_readplotdata
%  - sleepscoring>cb_grid75
%  - sleepscoring>cb_grid1s
%  - sleepscoring>cb_yu
%  - sleepscoring>cb_yd
%  - sleepscoring>cb_ylim

%-----------------%
%-read info
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');
dat = getappdata(h0, 'dat');
%-----------------%

%-------------------------------------%
%-main window
%-----------------%
%-plot data
delete(findobj(h0, 'tag', 'a_dat'))
axes(opt.axis.data);

delete(findobj(h0, 'tag', 'marker'))
plot_marker(info, opt)

plot_data(info, opt, dat);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-hypnogram
delete(findobj(opt.axis.hypno, 'tag', 'a_hypno'))
axes(opt.axis.hypno);

%-------%
%-info to hypnogram
opt.beginrec = info.beginrec;
opt.wndw = info.score(info.rater).wndw;
%-------%

plot_hypno(opt, info.score(info.rater))

score_popup(info, opt)
%-------------------------------------%

drawnow
