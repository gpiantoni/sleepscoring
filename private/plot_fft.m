function plot_fft(h, eventdata, chan_h)
%PLOT_FFT plot FFT of one channel,
%
% Called by
%  - cb_readplotdata (nargin == 1)
%  - cb_currentpoint>cb_wbup
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
cp = false; % current point plot
if nargin == 3
  
  %-called by cb_currentpoint
  cp = true;
  i_chan = h;
  if i_chan < 1; i_chan = 1; end
  if i_chan > numel(chan); i_chan = numel(chan); end
  
  begepoch = (opt.epoch-1) * info.score(info.rater).wndw * info.fsample;
  fftbeg = round(eventdata(1) * info.fsample - begepoch);
  fftend = round(eventdata(2) * info.fsample - begepoch);
  if fftbeg < 1; fftbeg = 1; end
  if fftend < size(dat,2); fftend = size(dat,2); end
  dat = dat(:, fftbeg:fftend);
  
elseif nargin == 2
  
  %-called by plot_fft
  opt.fft.i_chan = get(h, 'val');
  setappdata(h0, 'opt', opt)
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-plotting
delete(findobj(h0, 'parent', opt.h.fft))
ax = axes('parent', opt.h.fft, 'tag', 'a_fft');
set(ax, 'pos', [.05 .1 .9 .8], 'uni', 'norm');

%-----------------%
%-compute fft
% TODO: this should not use the signal toolbox
x = dat(opt.fft.i_chan, :);
[Pxx, f] = pwelch(x, info.fsample * opt.fft.welchdur, [], [], info.fsample);
%-----------------%

%-----------------%
%-find the chantype of the channel (so, it has the same color)
strcmpchan = @(x) any(strcmp(x, chan(opt.fft.i_chan)));
chantype = cellfun(strcmpchan, {opt.changrp.chan}); % chantype of the channel for fft
% TODO: maybe we can use scaling as well
%-----------------%

%-----------------%
%-plot
semilogy(f, Pxx, opt.changrp(chantype).linecolor);

if isfield(opt.fft, 'xlim') && ...
    ~isempty(opt.fft.xlim)
  xlim(opt.fft.xlim)
end

if isfield(opt.fft, 'ylim') && ...
    ~isempty(opt.fft.ylim)
  ylim(opt.fft.ylim)
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-add popup
if cp
  
  %-----------------%
  %-current point
  channame = ['!!!' chan{i_chan} '!!!'];
  uicontrol(opt.h.fft, 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .9 .9 .1], 'str', channame, 'val', 1, 'tag', 'popup_fft', ...
    'call', @plot_fft);
  %-----------------%
  
else
  
  %-----------------%
  %-normal fft
  uicontrol(opt.h.fft, 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .9 .9 .1], 'str', chan, 'val', opt.fft.i_chan, 'tag', 'popup_fft', ...
    'call', @plot_fft);
  %-----------------%
  
end
%-----------------%
%-------------------------------------%