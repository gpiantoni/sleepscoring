function [dat, sample] = read_data(info, opt, hdr)
%READ_DATA read data from disk
% 
% INFO
%  .score {3}: window length
%         {4}: beginning of epochs, in respect to beginning of the recordings
%  .rater: index of info.rater
%  .fsample: sampling frequency
%  .dataset: to read the data from
%
% OPT
%  .epoch: epoch of interest
%  .changrp: groups of channels to read
%    .chan: channel labels in the group
%    .ref: channel labels of the reference for this group
%    .scaling: rescale data
%    .Fhp: high-pass filter
%    .Flp: low-pass filter
%
% HDR
%
% Called by
%  - cb_readplotdata

persistent psetObj

%-----------------%
%-samples to read
wndw = info.score(info.rater).wndw;
beginsleep = info.score(info.rater).score_beg;

begsample = (opt.epoch - 1) * wndw * info.fsample + beginsleep * info.fsample;
endsample = begsample + wndw * info.fsample - 1;
sample = [begsample endsample];
%-----------------%

%-------------------------------------%
%-read channels and references
chan = [opt.changrp.chan];
ref = [opt.changrp.ref];

%-----------------%
%-channels in raw
chan_raw = unique([chan ref]);
[~, i_raw] = intersect(info.label, chan_raw);
[i_raw, si_raw] = sort(i_raw);
chan_raw = chan_raw(si_raw);
%-----------------%

% my hack for .pseth/.pset files
[~, ~, file_type] = fileparts(info.dataset);
if strcmpi(file_type, '.pseth'),
    if isempty(psetObj),
       psetObj = pset.load(info.dataset);           
    end
    raw = psetObj(i_raw, begsample:endsample);
else
    raw = ft_read_data(info.dataset, 'header', hdr, ...
        'begsample', begsample, 'endsample', endsample, 'chanindx', i_raw, ...
        'cache', false, 'checkboundary', false, ...
        'sequential', true); 
    % cache true might be faster but it does not read the whole dataset
    % sequential will be ignored by standard Fieldtrip, but the
    % enhance-mff-read branch of germangh/fieldtrip will read the file
    % faster if sequential=true
end
%-------------------------------------%

%-------------------------------------%
%-create dat (which is used for plotting)
nSamples = endsample - begsample + 1;
dat = zeros(numel(chan), nSamples);

i_chan = 0;

for i = 1:numel(opt.changrp)
  
  %-----------------%
  %-index of the channels in raw
  i_chan = (1:numel(opt.changrp(i).chan)) + i_chan(end);
  %-----------------%
  
  %-----------------%
  %-read data (assign correct position in the output dat matrix)
  for c = 1:numel(opt.changrp(i).chan)
    dat_idx = i_chan(c);
    raw_idx = strcmp(opt.changrp(i).chan{c}, chan_raw);
    dat(dat_idx,:) = raw(raw_idx, :);
  end
  %-----------------%
  
  %-----------------%
  %-re-reference
  if ~isempty(opt.changrp(i).ref)
    r_ref = ismember(chan_raw, opt.changrp(i).ref);
    ref = mean(raw(r_ref, :), 1);
    
    for c = i_chan
      dat(c,:) = dat(c,:) - ref;
    end
  end
  %-----------------%
  
  %-----------------%
  %-scaling
  dat(i_chan,:) = dat(i_chan,:) * opt.changrp(i).scaling;
  %-----------------%
  
  %-----------------%
  %-filtering
  Fhp = opt.changrp(i).Fhp;
  Flp = opt.changrp(i).Flp;
  
  if ~isempty(Fhp)
    dat(i_chan,:) = ft_preproc_highpassfilter(dat(i_chan,:), info.fsample, Fhp, 2);
  end
  
  if ~isempty(Flp)
    dat(i_chan,:) = ft_preproc_lowpassfilter(dat(i_chan,:), info.fsample, Flp);
  end
  %-----------------%

end
%-------------------------------------%
