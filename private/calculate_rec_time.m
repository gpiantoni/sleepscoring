function [rec_dur, rec_time, notnan] = calculate_rec_time(info, stage)
%CALCULATE_REC_TIME
%
% To mark lights-off and lights-on, you should mark the epochs of no
% interest when the lights were on as "NOT SCORED". The "NOT SCORED" epochs
% at the beginning and at the end will be considered to have the lights on
% (but not those in the middle of the recording).
% Lights-off becomes the first epoch WITHOUT a "NOT SCORED" and lights-off
% is the last epoch WITH a real score.
%
% Called by:
%  - report_rater
%  - scorewriting

score = info.score;
n_rater = size(score,2);
epoch_dur = [score.wndw]; % duration of each epoch

info_time = info.beginrec * 24 * 60 * 60; % absolute time of the beginning of the EEG, convert to seconds

%-----------------%
%-calculate beginning
notnan = zeros(2,n_rater);
for r = 1:n_rater
  i_notnan = find(~strcmp(score(r).stage, stage(1).label), 1); % where "stage(1).label" is the default score
  if i_notnan
    notnan(1,r) = i_notnan - 1; % index of the first non-nan
  end
end
rec_begin = [score.score_beg] + notnan(1,:) .* epoch_dur;
rec_time(1,:) = rec_begin + info_time; % in absolute terms
%-----------------%

%-----------------%
%-calculate end
for r = 1:n_rater
  i_notnan = find(~strcmp(score(r).stage, stage(1).label), 1, 'last');
  if i_notnan
    notnan(2,r) = i_notnan; % index of the first non-nan
  end
end
rec_end = [score.score_beg] + notnan(2,:) .* epoch_dur;
rec_time(2,:) = rec_end + info_time; % in absolute terms
%-----------------%

%-calculate recording time
rec_dur = rec_end - rec_begin;
%-------------------------------------%