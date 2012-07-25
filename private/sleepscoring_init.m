function [cfg opt] = sleepscoring_init(cfg, opt)
%SLEEPSCORING_INIT initialize sleep scoring when a new dataset has been
% loaded

%-----------------%
%-CFG 
cfg.label = feval(cfg.default.chan, cfg.hdr.label);

if isfield(cfg, 'score')
  cfg.rater = 1;
else
  cfg.score = [];
end

if ~isempty(cfg.score)
  cfg.wndw = cfg.score{3, cfg.rater};
else
  cfg.wndw = 30;
end
%-----------------%

%-----------------%
%-OPT
% .epoch and .begsample seems to give overlapping info, but .epoch refers
% to the sleep scoring epoch while .begsample refers to the data sample.
% The beginning of the sleep scoring need not coincide with the beginning
% of the recordings
opt.epoch = 1;
opt.begsample = 1;
opt.endsample = opt.begsample + cfg.hdr.Fs * cfg.wndw - 1;

for i = 1:numel(opt.changrp)
  [~, chanidx] = intersect(cfg.label, opt.changrp(i).chan);
  
  %-------%
  if numel(chanidx) ~= numel(opt.changrp(i).chan)
    nochan = setdiff(opt.changrp(i).chan, cfg.label);
    nochan = sprintf(' %s,', nochan{:});
    error(sprintf(['You want channels which are not in the data: ' nochan '\nBe careful with channame.m and the channel groups in opt_default.m']))
  end
  %-------%
  
  opt.changrp(i).chan = cfg.label(sort(chanidx))';
end
%-----------------%