function dat = readdata(cfg, opt)

%-------------------------------------%
chan = arrayfun(@(x) x.chan, opt.changrp, 'uni', 0);
chan = [chan{:}];
nSamples = opt.endsample - opt.begsample + 1;
dat = zeros(numel(chan), nSamples);

for i = 1:numel(opt.changrp)
  
  [changrp, i_raw] = intersect(cfg.label, opt.changrp(i).chan); % reorder alphabetically
  [i_raw, j] = sort(i_raw); % ft_read_data sorts the channels automatically, so we need to keep it into account
  chan_raw = changrp(j); % CHANNELS as in matrix RAW
  
  raw = ft_read_data(cfg.dataset, 'header', cfg.hdr, ...
    'begsample', opt.begsample, 'endsample', opt.endsample, 'chanindx', i_raw, ...
    'checkboundary', false); % for MEG data
  
  [rchangrp, ri_raw] = intersect(cfg.label, opt.changrp(i).ref); % reorder alphabetically
  [ri_raw, rj] = sort(ri_raw); % ft_read_data sorts the channels automatically, so we need to keep it into account
  rchan_raw = changrp(rj); % CHANNELS as in matrix RAW
  
  rraw = ft_read_data(cfg.dataset, 'header', cfg.hdr, ...
    'begsample', opt.begsample, 'endsample', opt.endsample, 'chanindx', ri_raw, ...
    'checkboundary', false); % for MEG data
  
  if isempty(rchan_raw)
    ref = raw;
  else
    ref = ft_preproc_rereference([raw; rraw], numel(chan_raw) + (1:numel(rchan_raw)));
  end

  [~,i1, i2] = intersect(chan, chan_raw);
  % dat(i1, :) = raw(i2, :);
  
  Fhp = []; opt.changrp(i).Fhp;
  Flp = []; opt.changrp(i).Flp;
  
  if ~isempty(Fhp)
    ref = ft_preproc_highpassfilter(ref, cfg.hdr.Fs, Fhp, 2); % TODO: it's not very efficient, it's computing bandpass even on reference channel
  end
  
  if ~isempty(Flp)
    ref = ft_preproc_lowpassfilter(ref, cfg.hdr.Fs, Flp);
  end
  
  dat(i1, :) = ref(i2, :) * opt.changrp(i).scaling;
end
%-------------------------------------%