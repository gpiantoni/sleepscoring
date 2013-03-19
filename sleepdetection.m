function sleepdetection(cfg, info)
%SLEEPDETECTION detect sleep parameters on info dataset
%
% CFG

% INFO
%  .dataset: the dataset to read, with the raw data
%  .infofile: the MAT file to save information to

[info, hdr] = prepare_info(info);
opt = prepare_opt(info.optfile);
[info, opt] = prepare_chan(info, opt);


keyboard

% check that at least one score exists
% use selected rater (info.rater)
% use selected epochs


%---------------------------%
%-epochs
epch = 1:10


%---------------------------%


%-----------------------------------------------%
%-loop over epochs
swall = [];

cnt = 0; % epoch count
nbad = 0; % bad electrodes


%---------------------------%
%-recreate data
data = [];
data.label = opt.changrp.chan;
data.fsample = info.fsample;
%---------------------------%

for e = epch
    
  %---------------------------%
  %-read data
  opt.epoch = e;
  [dat, sample] = read_data(info, opt, hdr);
  data.trial{1} = dat;

  %-----------------%
  %-get sample and time info
  data.sampleinfo = sample;
  data.time{1} = (sample(1):sample(2)) / info.fsample;
  %-----------------%
  %---------------------------%
  
  %---------------------------%
  %-ROIs
  mont = prepare_montage(cfg.roi, data.label);
  datroi = ft_apply_montage(data, mont, 'feedback', 'none');
  %---------------------------%
  
  %---------------------------%
  %-detection
  %-----------------%
  %-detect slow waves
  if isfield(cfg.detection, 'detsw') && ~isempty(cfg.detection.detsw)
    [sw] = detect_slowwave(cfg.detection.detsw, datroi);
    
    if ~isempty(sw)
      [sw.trl] = deal(e);
      swall = [swall sw];
    end
    
  end
  %-----------------%
  %---------------------------%
  
end
%-------------------------------------%

%---------------------------%
%-save file
%-----------------%
%-slow waves
if isfield(cfg.detection, 'detsw') && ~isempty(cfg.detection.detsw)
  
  %-------%
  %-pure duplicates
  % (because of padding the same data is used in two consecutive trials, for example)
  % check if the values of two negpeak in absolute samples are the same
  dupl = [true diff([swall.negpeak_iabs]) ~= 0];
  swall = swall(dupl);
  %-------%
  
  %-------%
  %-save
  slowwave = swall;
  swfile = sprintf('%sslowwave_stage%1d_%04d', cfg.detection.detdir, s, subj);
  save(swfile, 'slowwave')
  %-------%
  
end
%-----------------%

%-----------------%
%-spindles
if isfield(cfg.detection, 'detsp') && ~isempty(cfg.detection.detsp)
  
  %-------%
  %-pure duplicates
  % (because of padding the same data is used in two consecutive trials, for example)
  % check if the values of two negpeak in absolute samples are the same
  dupl = [true diff([spall.maxsp_iabs]) ~= 0];
  spall = spall(dupl);
  %-------%
  
  %-------%
  %-save
  spindle = spall;
  spfile = sprintf('%sspindle_stage%1d_%04d', cfg.detection.detdir, s, subj);
  save(spfile, 'spindle')
  %-------%
end
%-----------------%

%-----------------%
%-rem
if isfield(cfg.detection, 'detrem') && ~isempty(cfg.detection.detrem)
  
  %-------%
  %-pure duplicates
  % (because of padding the same data is used in two consecutive trials, for example)
  % check if the values of two negpeak in absolute samples are the same
  dupl = [true diff([remall.begin_iabs]) ~= 0];
  remall = remall(dupl);
  %-------%
  
  %-------%
  %-save
  rem = remall;
  remfile = sprintf('%srem_stage%1d_%04d', cfg.detection.detdir, s, subj);
  save(remfile, 'rem')
  %-------%
  
end
%-----------------%

output = sprintf('%saverage number of bad channels: % 5.f\n', output, nbad / numel(epch));
%---------------------------%

