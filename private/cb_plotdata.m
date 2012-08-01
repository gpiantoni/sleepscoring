function cb_plotdata(h0, eventdata)
%CB_PLOTDATA callback that only plots data

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
plot_data(info, opt, dat);
%-----------------%

%-----------------%
%-plot artifacts
delete(findobj('tag', 'artifact'))
% TODO: plot_artifact()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-hypnogram
delete(findobj('tag', 'a_hypno'))
axes('parent', findobj('tag', 'p_hypno'), 'tag', 'a_hypno');

%-------%
%-info to hypnogram
opt.beginrec = info.beginrec;
opt.wndw = info.score{3,info.rater};
opt.beginsleep = info.score{4,info.rater}(1);
%-------%

plot_hypno(opt, info.score(:, info.rater))

popup_score(info, opt)
%-------------------------------------%
