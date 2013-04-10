function output = report_rater(info, stage, tocsv)
%REPORT_RATER report info for each single rater

%-------------------------------------%
%-prepare input
if ~tocsv
  tab_size = 3;
  tab = @(x)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];
else
  tab = @(x)[x ','];
end

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
output = tab('');
for r = 1:n_rater
  output = [output tab(score(r).rater)];
end
output = [output '\n\n'];
%-----------------%

%-----------------%
%-Lights out clock time
output = [output tab('Lights out:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(rec_begin_abs(1,r)))];
end
output = [output '\n'];
%-----------------%

%-----------------%
%-Lights on clock time
output = [output tab('Lights on:')];
for r = 1:n_rater
  % don't use clock_score(2,r) but use the last epoch which was scored as non-nan
  output = [output tab(s2hhmm(rec_end_abs(1,r)))];
end
output = [output '\n\n'];
%-----------------%

%-----------------%
%-Total sleep time (TST)
output = [output tab('Total Sleep Time:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(tst(1,r)))];
end
output = [output '\n'];
%-----------------%

%-----------------%
%-Total recording time ("lights out" to "lights on")
output = [output tab('Recording Time:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(rec_time(1,r)))];
end
output = [output '\n\n'];
%-----------------%

%-----------------%
%-Sleep latency (SL; lights out to first epoch of any sleep)
output = [output tab('Sleep Latency:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(sl(1,r)))];
end
output = [output '\n'];
%-----------------%

%-----------------%
%-Sleep latency (SL; lights out to first epoch of any sleep)
output = [output tab('REM Latency:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(l_rem(1,r)))];
end
output = [output '\n\n'];
%-----------------%

%-----------------%
%-WASO (Wake after sleep onset)
output = [output tab('WASO:')];
for r = 1:n_rater
  output = [output tab(s2hhmm(waso(1,r)))];
end
output = [output '\n'];
%-----------------%

%-----------------%
%-WASO (Wake after sleep onset)
output = [output tab('Efficiency:')];
for r = 1:n_rater
  output = [output sprintf(tab('% 10.2f%%'), efficiency(1,r))];
end
output = [output '\n\n'];
%-----------------%

%-----------------%
%-stages duration and percentage
for s = 1:n_stage
  
  output = [output tab(stage(s).label)];
  for r = 1:n_rater
    output = [output tab(s2hhmm(ep(s, r)))];
  end
  output = [output '\n'];
  
  output = [output tab(' Percent ')];
  for r = 1:n_rater
    output = [output sprintf(tab('% 10.2f%%'), ep(s, r) / tst(1,r) * 100)];
  end
  output = [output '\n'];
  
end
output = [output '\n'];
%-----------------%

%-----------------%
%-markers
for i = 1:numel(mrk)
  output = [output sprintf(tab('%s (num)'), mrk{i})];
  output = [output sprintf(tab('% 7d'), mrk_n(i,:))];
  output = [output '\n'];
  
  output = [output tab('  - (dur)')];
  output = [output sprintf(tab('% 10.2fs'), mrk_d(i,:))];
  output = [output '\n'];
end
%-----------------%

output = strrep(output, '%', '%%'); % escape "escape char"
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
