function plotfft(hObject, eventdata)

%-------------------------------------%
%-general info
%-----------------%
%-read info
cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
dat = getappdata(0, 'dat');

chan = [opt.changrp.chan];
%-----------------%

%-----------------%
%-read label
cp = false; % current point plot
if nargin > 0 
  
  if ~isempty(eventdata) && numel(eventdata) == 2
    
    %-called by cb_currentpoint
    cp = true;
    i_chan = hObject;
    if i_chan < 1; i_chan = 1; end
    if i_chan > numel(chan); i_chan = numel(chan); end
    
    fftbeg = eventdata(1);
    fftend = eventdata(2);
    if fftbeg < 1; fftbeg = 1; end
    if fftend < size(dat,2); fftend = size(dat,2); end
    dat = dat(:, fftbeg:fftend);
    
  else
    
    %-called by popup
    opt.fft.i_chan = get(hObject, 'val');
    setappdata(0, 'opt', opt)
    
  end
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-plotting
delete(findobj('parent', opt.h.fft))
ax = axes('parent', opt.h.fft, 'tag', 'a_fft');
set(ax, 'pos', [.05 .1 .9 .8], 'uni', 'norm');

%-----------------%
%-compute fft
% TODO: this should not use the signal toolbox
x = dat(opt.fft.i_chan, :);
[Pxx, f] = pwelch(x, cfg.fsample * opt.fft.welchdur, [], [], cfg.fsample);
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
  channame = ['!!! ' chan{i_chan} '!!!'];
  uicontrol(opt.h.fft, 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .9 .9 .1], 'str', channame, 'val', 1, 'tag', 'popup_fft', ...
    'call', @plotfft);
  %-----------------%
  
else
  
  %-----------------%
  %-normal fft
  uicontrol(opt.h.fft, 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .9 .9 .1], 'str', chan, 'val', opt.fft.i_chan, 'tag', 'popup_fft', ...
    'call', @plotfft);
  %-----------------%
  
end
%-----------------%
%-------------------------------------%