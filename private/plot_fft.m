function plot_fft(h, eventdata)
%PLOT_FFT plot FFT of one channel,
%
% Called by
%  - cb_readplotdata (nargin == 1)
%  - plot_fft

%-------------------------------------%
%-general info
%-----------------%
%-read info
h0 = get_parent_fig(h);

info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');
dat = getappdata(h0, 'dat');

chan = [opt.changrp.chan];
%-----------------%

%-----------------%
%-read label
if nargin == 2
  
  %-called by plot_fft
  opt.fft.i_chan = get(h, 'val');
  setappdata(h0, 'opt', opt)
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-plotting
delete(get(opt.h.axis.fft, 'child'))
set(opt.h.axis.fft, 'pos', [.05 .1 .9 .8], 'uni', 'norm');

%-----------------%
%-compute fft
% TODO: this should not use the signal toolbox
x = dat(opt.fft.i_chan, :);
[Pxx, f] = pwelch(x, info.fsample * opt.fft.welchdur, [], [], info.fsample);
%-----------------%

%-----------------%
%-find the chantype of the channel (so, it has the same color)
n_changrp = cumsum(cellfun(@numel, {opt.changrp.chan}));
chantype = find(opt.fft.i_chan <= n_changrp, 1);
% TODO: maybe we can use scaling as well
%-----------------%

%-----------------%
%-plot
semilogy(opt.h.axis.fft, f, Pxx, opt.changrp(chantype).linecolor);

if isfield(opt.fft, 'xlim') && ...
    ~isempty(opt.fft.xlim)
  set(opt.h.axis.fft, 'xlim', opt.fft.xlim)
end

if isfield(opt.fft, 'ylim') && ...
    ~isempty(opt.fft.ylim)
  set(opt.h.axis.fft, 'ylim', opt.fft.ylim)
end
%-----------------%

%-----------------%
%-add popup
%TODO
uicontrol(opt.h.panel.fft.h, 'sty', 'popup', 'uni', 'norm', ...
  'pos', [.05 .9 .9 .1], 'str', chan, 'val', opt.fft.i_chan, 'tag', 'popup_fft', ...
  'call', @plot_fft);
%-----------------%
%-------------------------------------%
