function sleepdetection(cfg, info)
%SLEEPDETECTION detect sleep parameters on info dataset





%SLEEPDETECTION detect slow waves, spindles, and REM
%
% CFG
%  .stages: stages to analyze
%
% (optional)
%  .rater: index of the sleep rater (if not specified, it uses the default in info.rater)


%  .rec: name of the recording
%  .data: name of projects/PROJNAME/subjects/
%  .mod: recording modality (likely 'eeg')
%
%
%  .sleepepochs.feedback: gives feedback or no of each epoch (logical, default: false)
%  .sleepepochs.pad: amount of padding for each epoch (default: 1s)
%  .sleepepochs.visrej: use visual rejection from sleep scoring (logical)
%  .sleepepochs.chanrej: reject channels outside the limit (TODO)
%
%  .sleepepochs.reref: if not empty, re-referencing
%  .sleepepochs.reref.refchannel: channels used for re-referencing ({'E94' 'E190'} or 'all')
%  .sleepepochs.reref.implicit: implicit channel ('E257')
%
%  .sleepepochs.detdir: directory where you want to save the slow waves
%  .sleepepochs.detsw: if not empty, slow wave detection, you should use the
%                      configuration options based on DETECT_SLOWWAVE
%  .sleepepochs.detsp: if not empty, spindle detection, you should use the
%                      configuration options based on DETECT_SPINDLE
%
% INPUT

%-----------------------------------------------%
%-check input
%---------------------------%
%-CFG
if ~isfield(cfg, 'detection'); cfg.detection = []; end
if ~isfield(cfg.detection, 'feedback'); cfg.detection.feedback = false; end
if ~isfield(cfg.detection, 'visrej');   cfg.detection.visrej = true; end
if ~isfield(cfg.detection, 'chanrej');  cfg.detection.chanrej = false; end
%---------------------------%

%---------------------------%
%-INFO
% Two ways:
% - interactive, by passing cfg and info or infofile
% - batch, by passing cfg and subj
% in any case, you get the cfg and info to work with
%---------------------------%

%---------------------------%
%-SCORE
if isfield(cfg, 'rater')
  info.rater = cfg.rater; % used by read_data
end

score = info.score(:, info.rater);
epch = find(ismember(score{1}, cfg.stage)); % epochs to read
%---------------------------%

%---------------------------%
%-VISUAL ARTIFACTS
if ~isempty(score{5})
  artbeg = round(score{5}(:,1) * info.fsample); % from time into samples
  artend = round(score{5}(:,2) * info.fsample); % from time into samples
  art = [artbeg artend];
  
else
  art = [];
  
end
%---------------------------%
%-----------------------------------------------%

%-----------------------------------------------%
%-loop over epochs
swall = [];
spall = [];
remall = [];

cnt = 0; % epoch count
nbad = 0; % bad electrodes

%---------------------------%
%-HDR: read header once
hdr = ft_read_header(info.dataset);
%---------------------------%

%---------------------------%
%-OPT
opt.changrp.chantype = 'toread';
opt.changrp.chan = {'E233'}; % {roi.chan}
opt.changrp.ref = {}; % to specify
opt.changrp.Fhp = 0.1; % to specify
opt.changrp.Flp = 12; % to specify
opt.changrp.scaling = 1;
%---------------------------%

%---------------------------%
%-recreate data
data = [];
data.label = opt.changrp.chan;
%---------------------------%

for e = epch
  
  %---------------------------%
  %-progress
  cnt = cnt + 1;
  if cfg.detection.feedback
    fprintf('stage %d/%d\n', cnt, numel(epch))
  end
  %---------------------------%
  
  %---------------------------%
  %-read data
  opt.epoch = e;
  dat = read_data(info, opt, hdr);
  data.trial{1} = dat;

  %-----------------%
  %-get sample and time info
  wndw = info.score{3,info.rater};
  beginsleep = info.score{4,info.rater}(1);
  begsample = (opt.epoch - 1) * wndw * info.fsample + beginsleep * info.fsample;
  endsample = begsample + wndw * info.fsample - 1;
  
  data.sampleinfo = [begsample endsample];
  data.time{1} = (begsample:endsample) / info.fsample;
  %-----------------%
  %---------------------------%
  
  %---------------------------%
  %-reject artifacts
  %-----------------%
  %-visual rejection during visual scoring
  if cfg.detection.visrej
    try
      tmpcfg = [];
      tmpcfg.artfctdef.manual.artifact = art;
      tmpcfg.artfctdef.reject = 'partial';
      tmpcfg.artfctdef.minaccepttim = 2;
      data = ft_rejectartifact(tmpcfg, data);
      data.fsample = info.fsample; % rounding error introduced by ft_rejectartifact
    catch
      output = sprintf('%sComplete rejection of epoch % 3.f\n', output, e);
      continue
    end
  end
  %-----------------%
  
  %-----------------%
  %-remove nan
  for i = 1:numel(data.trial)
    data.trial{i}(isnan(data.trial{i})) = 0;
  end
  %-----------------%
  
  %-----------------%
  %-clean bad channels
  if cfg.detection.chanrej
    [data outtmp] = chanart(cfg, data);
    output = [output outtmp];
  end
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
    [sw] = detect_slowwave(cfg.detection.detsw, data);
    
    if ~isempty(sw)
      [sw.trl] = deal(e);
      swall = [swall sw];
    end
    
  end
  %-----------------%
  
  %-----------------%
  %-detect spindles
  if isfield(cfg.detection, 'detsp') && ~isempty(cfg.detection.detsp)
    [sp] = detect_spindle(cfg.detection.detsp, data);
    
    if ~isempty(sp)
      [sp.trl] = deal(e);
      spall = [spall sp];
    end
  end
  %-----------------%
  
  %-----------------%
  %-detect rem
  if isfield(cfg.detection, 'detrem') && ~isempty(cfg.detection.detrem)
    [rem] = detect_rem(cfg.detection.detrem, data);
    
    if ~isempty(rem)
      [rem.trl] = deal(e);
      remall = [remall rem];
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

