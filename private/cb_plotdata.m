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
%-refresh only data window
%-----------------%
%-plot markers
plot_marker(info, opt)
%-----------------%

%-----------------%
%-plot data
plot_data(info, opt, dat);
%-----------------%
%-------------------------------------%

drawnow
