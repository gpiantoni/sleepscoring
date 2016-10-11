function [det, PSD] = compute_psd(cfg, data)
%COMPUTE_PSD compute power-spectrum density
% Very straightforward Welch's method: first chop the 30s sleep scoring
% window into smaller epochs (default 2s long), then compute power spectrum
% on each epoch for each frequency of interest. Compute the log of the
% resulting PSD and average over epochs (so that you have one value for
% each frequency, for each 30s window)
%
% Use as:
%    [det, PSD] = compute_psd(cfg, data)
%
%  (optional)
%  .freq = [1 50]; frequency interval in Hz
%  .length = 2; length of the smaller epochs, in seconds
%  .overlap = .5; amount of overlap of epochs (default: 50%)
%  .log = true; take the log before taking the mean over frequency
%  (strongly adviced!)
%
% det
%    empty output, because we are not detecting anything here
%
% PSD
%    label: channel labels
%    freq : frequency band where psd was computed
%    psd : power spectrum density, averaged over frequency bands

%---------------------------%
%-prepare input
%-----------------%
%-check cfg
%-------%
%-defaults
if ~isfield(cfg, 'freq'); cfg.freq = [1 50]; end
if ~isfield(cfg, 'length'); cfg.length = 2; end
if ~isfield(cfg, 'overlap'); cfg.overlap = 0.5; end
if ~isfield(cfg, 'log'); cfg.log = true; end
%-------%
%-----------------%
%---------------------------%

%---------------------------%
%-output
det = [];

%-----------------%
%-create short trials
cfg1 = [];
cfg1.length = cfg.length;
cfg1.overlap = cfg.overlap;
data1 = ft_redefinetrial(cfg1, data);
%-----------------%

%-----------------%
%-compute frequency analysis
cfg1 = [];
cfg1.method = 'mtmfft';
cfg1.taper = 'hanning';
cfg1.feedback = 'none';
cfg1.foilim = cfg.freq;
freq = ft_freqanalysis(cfg1, data1);
%-----------------%

%-----------------%
%-prepare output
PSD.label = freq.label;
PSD.freq = cfg.freq;

if cfg.log
    PSD.psd = mean(log(freq.powspctrm), 2);
else
  PSD.psd = mean(freq.powspctrm, 2);
end
%-----------------%
%---------------------------%