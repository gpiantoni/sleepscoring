function report_rater(info, stage)
%REPORT_RATER report info for each single rater

%-------------------------------------%
%-prepare input
tab_size = 3;
tab = @(x)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];

score = info.score;
n_stage = numel(stage);
n_rater = size(score,2);

mrk = arrayfun(@(x) {x.marker.name}, score, 'uni', false);
mrk = unique([mrk{:}]);
%-------------------------------------%

%-------------------------------------%
%-calculate recording time
% The correct way to identify the beginning of the scoring period ("lights
% out") is by right-clicking on the sleep epochs and define the beginning
% of the scoring window. Another way is to mark the epochs of no interest
% as "NaN" (so, not scored). When computing total recording time and sleep
% efficiency, we need to take into account both possible ways.
epoch_dur = [score.wndw]; % duration of each epoch

info_time = info.beginrec * 24 * 60 * 60; % absolute time of the beginning of the EEG, convert to seconds

%-----------------%
%-calculate beginning
i_first_notnan = zeros(1,n_rater);
for r = 1:n_rater
  i_notnan = find(~strcmp(score(r).stage, stage(1).label), 1); % where "stage(1).label" is the default score
  if i_notnan
    i_first_notnan(r) = i_notnan - 1; % index of the first non-nan
  end
end
rec_begin = [score.score_beg] + i_first_notnan .* epoch_dur;
rec_begin_abs = rec_begin + info_time; % in absolute terms
%-----------------%

%-----------------%
%-calculate end
i_last_notnan = zeros(1,n_rater);
for r = 1:n_rater
  i_notnan = find(~strcmp(score(r).stage, stage(1).label), 1, 'last');
  if i_notnan
    i_last_notnan(r) = i_notnan; % index of the first non-nan
  end
end
rec_end = [score.score_beg] + i_last_notnan .* epoch_dur;
rec_end_abs = rec_end + info_time; % in absolute terms
%-----------------%

%-calculate recording time
rec_time = rec_end - rec_begin;
%-------------------------------------%

%-------------------------------------%
%-collect scores, across raters
ep = zeros(n_stage, n_rater); % n of epochs in each stage
l = nan(n_stage, n_rater); % latency
mrk_n = zeros(numel(mrk), n_rater); % number of markers
mrk_d = zeros(numel(mrk), n_rater); % duration of markers

for r = 1:n_rater;
  
  effectivescore = score(r).stage(i_first_notnan(r)+1:i_last_notnan(r));
  
  %-----------------%
  %-count number of epochs in each stage
  for s = 1:n_stage
    
    f = find(strcmp(effectivescore, stage(s).label));
    if ~isempty(f)
      ep(s, r) = numel(f);
      l(s, r) = f(1) - 1;
    end
    
  end
  %-----------------%
  
  %-----------------%
  %-into seconds
  ep(:, r) = ep(:, r) * epoch_dur(r);
  l(:, r) = l(:, r) * epoch_dur(r);
  %-----------------%
  
  %-----------------%
  %-markers
  for i = 1:numel(mrk)
    i_mrk = strcmp({score(r).marker.name}, mrk{i});
    mrk_n(i,r) = size(score(r).marker(i_mrk).time,1);
    mrk_d(i,r) = sum(diff(score(r).marker(i_mrk).time, [], 2));
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-compute sleep parameters
ep_sleep = ep(~[stage.awake], :);
l_sleep = l(~[stage.awake], :);

tst = sum(ep_sleep);
sl = min(l_sleep);
efficiency = tst ./ rec_time * 100;
%-------------------------------------%

%-------------------------------------%
%-stage-specific parameters
%-----------------%
%-REM latency from sleep onset
[~, i_rem] = intersect({stage.label}, {'rem' 'REM' 'REM Sleep' 'REM sleep' 'REMSleep' 'REMsleep'}); % find rem sleep
l_rem = l(i_rem,:) - min(l_sleep);
%-----------------%

%-----------------%
%-WASO Stage W during TST minus sleep latency
waso = sum(ep([stage.awake],:),1);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-give output based on AASM 2007 manual
% each \t is every 8 characters
%-----------------%
%-name of the rater
fprintf('\t\t\t')
for r = 1:n_rater
  fprintf(tab(score(r).rater))
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
fprintf('\n')
%-----------------%

%-----------------%
%-markers
for i = 1:numel(mrk)
  fprintf('%s (num)\t\t', mrk{i})
  fprintf('% 7d\t\t\t', mrk_n(i,:))
  fprintf('\n')
  
  fprintf('  - (dur)\t\t')
  fprintf('% 10.2fs\t\t', mrk_d(i,:))
  fprintf('\n')
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
