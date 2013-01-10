function report_rater(info, stage)
%REPORT_RATER report info for each single rater

%-------------------------------------%
%-prepare input
wakefulness_code = [0 6]; % which code corresponds to wakefulness (wake/movement)

tab_size = 3;
tab = @(x)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];

score = info.score;
n_stage = numel(stage);
n_rater = size(score,2);
%-------------------------------------%

%-------------------------------------%
%-calculate recording time
% The correct way to identify the beginning of the scoring period ("lights
% out") is by right-clicking on the sleep epochs and define the beginning
% of the scoring window. Another way is to mark the epochs of no interest
% as "NaN" (so, not scored). When computing total recording time and sleep
% efficiency, we need to take into account both possible ways.
epoch_dur = [score{3,:}]; % duration of each epoch

info_time = info.beginrec * 24 * 60 * 60; % absolute time of the beginning of the EEG, convert to seconds

%-----------------%
%-calculate beginning
rec_begin_end = cat(1, score{4,:})'; % in seconds
rec_begin = rec_begin_end(1,:); % 1) proper way, sleep is marked using right-click on sleep scoring
i_first_notnan = nan(1,n_rater);
for r = 1:n_rater
  i_notnan = find(~isnan(score{1,r}), 1);
  if i_notnan
    i_first_notnan(1,r) = i_notnan - 1; % index of the first non-nan
  end
end
rec_begin = rec_begin + i_first_notnan .* epoch_dur;
rec_begin_abs = rec_begin + info_time; % in absolute terms
%-----------------%

%-----------------%
%-calculate end
i_last_notnan = nan(1,n_rater);
for r = 1:n_rater
  i_notnan = find(~isnan(score{1,r}), 1, 'last');
  if i_notnan
    i_last_notnan(1,r) = i_notnan; % index of the first non-nan
  end
end
rec_end = rec_begin_end(1,:) + i_last_notnan .* epoch_dur;
rec_end_abs = rec_end + info_time; % in absolute terms
%-----------------%

%-calculate recording time
rec_time = rec_end - rec_begin;
%-------------------------------------%

%-------------------------------------%
%-collect scores, across raters
ep = zeros(n_stage, n_rater); % n of epochs in each stage
l = nan(n_stage, n_rater); % latency

for r = 1:n_rater;
  
  %-----------------%
  %-count number of epochs in each stage
  for s = 1:n_stage
    
    if ~isnan(stage(s).code)
      f = find(score{1, r} == stage(s).code);
      
      if ~isempty(f)
        ep(s, r) = numel(f);
        l(s, r) = f(1);
      end
    end
    
  end
  %-----------------%
  
  %-----------------%
  %-into seconds
  ep(:, r) = ep(:, r) * epoch_dur(r);
  l(:, r) = l(:, r) * epoch_dur(r);
  %-----------------%
  
  %-----------------%
  %-artifacts
  %TODO: count artifacts
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-compute sleep parameters
%-----------------%
%-find index of sleep epochs
% not scored
[~, i_notscored] = find(isnan([stage.code])); % NaN is always "not sleep"
% wakefulness
[~, i_wake] = intersect([stage.code], wakefulness_code);
% sleep
i_sleep = setdiff(1:n_stage, [i_wake i_notscored]);
%-----------------%

ep_sleep = ep(i_sleep, :);
l_sleep = l(i_sleep, :);

tst = sum(ep_sleep);
sl = min(l_sleep) - epoch_dur - i_first_notnan .* epoch_dur;
efficiency = tst ./ rec_time * 100;
%-------------------------------------%

%-------------------------------------%
%-stage-specific parameters
%-----------------%
%-REM latency from sleep onset
[~, i_rem] = intersect({stage.label}, {'rem' 'REM' 'REM Sleep' 'REM sleep'}); % find rem sleep
l_rem = l(i_rem,:) - min(l_sleep);
%-----------------%

%-----------------%
%-WASO Stage W during TST minus sleep latency
ep_wake = sum(ep(i_wake,:),1);
waso = ep_wake - sl;
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-give output based on AASM 2007 manual
% each \t is every 8 characters
%-----------------%
%-name of the rater
fprintf('\t\t\t')
for r = 1:n_rater
  fprintf(tab(score{2,r}))
end
fprintf('\n\n')
%-----------------%

%-----------------%
%-Lights out clock time
fprintf(['Lights out:\t\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(rec_begin_abs(1,r))))
end
fprintf('\n')
%-----------------%

%-----------------%
%-Lights on clock time
fprintf(['Lights on:\t\t'])
for r = 1:n_rater
  % don't use clock_score(2,r) but use the last epoch which was scored as non-nan
  fprintf(tab(s2hhmm(rec_end_abs(1,r))))
end
fprintf('\n\n')
%-----------------%

%-----------------%
%-Total sleep time (TST)
fprintf(['Total Sleep Time:\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(tst(1,r))))
end
fprintf('\n')
%-----------------%

%-----------------%
%-Total recording time ("lights out" to "lights on")
fprintf(['Recording Time:\t\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(rec_time(1,r))))
end
fprintf('\n\n')
%-----------------%

%-----------------%
%-Sleep latency (SL; lights out to first epoch of any sleep)
fprintf(['Sleep Latency:\t\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(sl(1,r))))
end
fprintf('\n')
%-----------------%

%-----------------%
%-Sleep latency (SL; lights out to first epoch of any sleep)
fprintf(['REM Latency:\t\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(l_rem(1,r))))
end
fprintf('\n\n')
%-----------------%

%-----------------%
%-WASO (Wake after sleep onset)
fprintf(['WASO:\t\t\t'])
for r = 1:n_rater
  fprintf(tab(s2hhmm(waso(1,r))))
end
fprintf('\n')
%-----------------%

%-----------------%
%-WASO (Wake after sleep onset)
fprintf(['Efficiency:\t\t'])
for r = 1:n_rater
  fprintf('% 10.2f%%\t\t', efficiency(1,r))
end
fprintf('\n\n')
%-----------------%

%-----------------%
%-stages duration and percentage
for s = 1:n_stage
  
  if ~isnan(stage(s).code) % not meaningful for NOT SCORED
    
    fprintf(tab(stage(s).label))
    for r = 1:n_rater
      fprintf(tab(s2hhmm(ep(s, r))))
    end
    fprintf('\n')
    
    fprintf([' Percent \t\t'])
    for r = 1:n_rater
      fprintf('% 10.2f%%\t\t', ep(s, r) / tst(1,r) * 100)
    end
    fprintf('\n')
    
  end
  
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-SUBFUNCTIONS------------------------%
%-------------------------------------%

%-------------------------------------%
%-convert time in hour-minutes-seconds format
function hhmm = s2hhmm(s)

if isnan(s)
  hhmm = '       n.a.';
else
  hhmm = datestr(s / 24 / 60 / 60, 'HHMMSS');
  hhmm = [hhmm(1:2) 'h ' hhmm(3:4) 'm ' hhmm(5:6) 's'];
end
%-------------------------------------%
