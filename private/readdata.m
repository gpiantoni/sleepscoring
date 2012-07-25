function dat = readdata2(cfg, opt)

%-------------------------------------%
%-read channels and references
chan = arrayfun(@(x) x.chan, opt.changrp, 'uni', 0);
chan = [chan{:}];
ref = arrayfun(@(x) x.ref, opt.changrp, 'uni', 0);
ref = [ref{:}];

%-----------------%
%-channels in raw
chan_raw = unique([chan ref]);
[~, i_raw] = intersect(cfg.label, chan_raw);
[i_raw, si_raw] = sort(i_raw);
chan_raw = chan_raw(si_raw);
%-----------------%

raw = ft_read_data(cfg.dataset, 'header', cfg.hdr, ...
  'begsample', opt.begsample, 'endsample', opt.endsample, 'chanindx', i_raw, ...
  'cache', false); % cache true might be faster but it does not read the whole dataset
%-------------------------------------%

%-------------------------------------%
%-create dat (which is used for plotting)
nSamples = opt.endsample - opt.begsample + 1;
dat = zeros(numel(chan), nSamples);

for i = 1:numel(opt.changrp)
  
  %-----------------%
  %-reference data
  r_chan = ismember(chan_raw, opt.changrp(i).chan);
  if ~isempty(opt.changrp(i).ref)
    r_ref = ismember(chan_raw, opt.changrp(i).ref);
  else
    r_ref = false(size(chan_raw));
  end
  
  r = r_chan | r_ref;
  chan_in_reref = ismember(find(r), find(r_chan));
  ref_in_reref = ismember(find(r), find(r_ref));
  
  chan_reref = chan_raw(r); % channels in reref
  reref = raw(r,:);
  %-----------------%
  
  %-----------------%
  %-reref
  if any(r_ref)
    reref = ft_preproc_rereference(reref, ref_in_reref);
  end
  
  reref = reref(chan_in_reref,:) * opt.changrp(i).scaling; % reassignment of REREF with only channels of interest
  %-----------------%
  
  %-----------------%
  %-filtering
  Fhp = opt.changrp(i).Fhp;
  Flp = opt.changrp(i).Flp;
  
  if ~isempty(Fhp)
    reref = ft_preproc_highpassfilter(reref, cfg.hdr.Fs, Fhp, 2);
  end
  
  if ~isempty(Flp)
    reref = ft_preproc_lowpassfilter(reref, cfg.hdr.Fs, Flp);
  end
  %-----------------%
  
  [dat_chan] = ismember(chan, opt.changrp(i).chan);
  dat(dat_chan, :) = reref; % TODO: This only works because chan and chan_reref are sorting in the same way
  
end
%-------------------------------------%
