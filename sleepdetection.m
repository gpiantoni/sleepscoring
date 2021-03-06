function info = sleepdetection(cfg, info, opt)
%SLEEPDETECTION detect sleep parameters on info dataset
%
% CFG
%  .method*: a struct with
%    .name*: name of the marker
%    .fun*: subfunction to call
%    .chan*: channels to read, see FT_CHANNELSELECTION
%    .ref: channels to use as reference
%    .Fhp: freq for high-pass filter (not necessary but advised!)
%    .Flp: freq for low-pass filter
%    .cfg: options to pass to the subfunction
%    .epoch: as boolean, OR as vector (indices of the epochs) OR as string 
%      for sleep stages of interest ('NREM 2' OR {'NREM 2', 'NREM 3'})
%
%  .rater: name or index of the rater (otherwise, it uses info.rater)
%
% INFO
%  will be passed and read by PREPARE_INFO
%
% OPT (optional)
%  .stage*: output of HYPNOGRAM_XXX.m in preference folder
%
% * indicates obligatory parameter

orig_state = warning;
warning('off', 'all')

%---------------------------%
[info, hdr] = prepare_info(info);

if nargin <= 2
  opt = prepare_opt(info.optfile);
elseif ~isfield(opt, 'changrp') || ~isfield(opt.changrp, 'chan')
  opt.changrp.chan = info.label;
end
[info, opt] = prepare_chan(info, opt);
%---------------------------%

% check that at least one score exists

%---------------------------%
%-select rater
if isfield(cfg, 'rater')
  if ischar(cfg.rater)
    rater = find(strcmp({info.score.rater}, cfg.rater));
    
  else
    rater = cfg.rater;
    
  end
  
else
  rater = info.rater;
  
end
%---------------------------%

%-----------------------------------------------%`]
%-loop over detection methods
for i = 1:numel(cfg.method)
  
  %---------------------------%
  if ~isfield(cfg.method(i), 'cfg')
    cfg.method(i).cfg = [];
  end
  %---------------------------%
  
  %---------------------------%
  %-existing marker or new marker
  i_mrk = numel(info.score(rater).marker) + 1;
  info.score(rater).marker(i_mrk).name = cfg.method(i).name;
  %---------------------------%
  
  %---------------------------%
  %-find epochs
  if ~isfield(cfg.method(i), 'epoch')
    epch = 1:info.score(rater).nepoch;
    
  else
    
    if islogical(cfg.method(i).epoch)
      epch = find(cfg.method(i).epoch);
      
    elseif isnumeric(cfg.method(i).epoch)
      epch = cfg.method(i).epoch;
      
    elseif ischar(cfg.method(i).epoch) || iscell(cfg.method(i).epoch)
      if ischar(cfg.method(i).epoch)
        cfg.method(i).epoch = {cfg.method(i).epoch};
      end
      
      if all(cellfun(@isempty, info.score(rater).stage))
        error('There is no sleep score for rater %s', ...
              info.score(rater).rater)
      end
            
      epch = find(ismember(info.score(rater).stage, cfg.method(i).epoch));
      
    end
    
  end
  %---------------------------%
  
  %---------------------------%
  %-channels
  opt.changrp = [];
  opt.changrp.chantype = 'toread';
  opt.changrp.chan = ft_channelselection(cfg.method(i).chan, info.label)';
  if isfield(cfg.method(i), 'ref')
    opt.changrp.ref = ft_channelselection(cfg.method(i).ref, info.label)';
  end
  opt.changrp.scaling = 1;
  
  if isfield(cfg.method(i), 'Fhp')
    opt.changrp.Fhp = cfg.method(i).Fhp;
  else
    opt.changrp.Fhp = [];
  end
  
  if isfield(cfg.method(i), 'Flp')
    opt.changrp.Flp = cfg.method(i).Flp;
  else
    opt.changrp.Flp = [];
  end
  %---------------------------%
  
  %---------------------------%
  %-channels
  data = [];
  data.label = opt.changrp.chan;
  data.fsample = info.fsample;
  %---------------------------%

  %-------------------------------------%
  for i_e = 1:numel(epch)
    e = epch(i_e);
    fprintf('Processing epoch % 6d/% 6d\n', i_e, numel(epch));
    
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
    %-detection
    if nargout(cfg.method(i).fun) == 1
      mrk = feval(cfg.method(i).fun, cfg.method(i).cfg, data);
      
    elseif nargout(cfg.method(i).fun) == 2
      [mrk, extra] = feval(cfg.method(i).fun, cfg.method(i).cfg, data);
      
      if ~isempty(extra)
        [extra.trl] = deal(e);  % index of the trial
        
        if isfield(info.score(rater).marker(i_mrk), 'extra')
          info.score(rater).marker(i_mrk).extra = [info.score(rater).marker(i_mrk).extra extra];
        else
          info.score(rater).marker(i_mrk).extra = [];
        end
      end
      
    end
    
    if ~isfield(info.score(rater).marker(i_mrk), 'time')
      info.score(rater).marker(i_mrk).time = [];
    end
    info.score(rater).marker(i_mrk).time = [info.score(rater).marker(i_mrk).time; mrk];
    %---------------------------%
    
  end
  
  % too slow
  % info.score(rater).marker(i_mrk).time = merge_intervals(info.score(rater).marker(i_mrk).time);
  %-------------------------------------%
  
end
%-----------------------------------------------%

warning(orig_state);
