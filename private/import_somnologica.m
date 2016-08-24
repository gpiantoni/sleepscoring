function score = import_somnologica(somno_file, info)
%IMPORT_SOMNOLOGICA import scores from somnologica, as Events.txt
%
% INPUT
% somno_file : path to somnological events.txt file
% info : struct with the dataset info
%
% OUTPUT
% score : the exported score

%-----------------%
%-read header
fid = fopen(somno_file);
for i = 1:3
  fgetl(fid); % header
end

s_recdate = fgetl(fid);
str_recdate = strtrim(s_recdate(16:end));

for i = 1:9
  fgetl(fid); % header
end

s_scorer = fgetl(fid);
rater = strtrim(s_scorer(13:end));

for i = 1:3
  fgetl(fid); % header
end
%-----------------%

%-----------------%
%-read first epoch (for epoch durations and start time of scoring)
s_epoch = fgetl(fid);
tabs = strfind(s_epoch, sprintf('\t'));

epoch_dur = str2double(s_epoch(tabs(end):end));

first_epoch_datetime = get_epoch_datetime(s_epoch, str_recdate);
score_beg = (first_epoch_datetime - info.beginrec) * 24 * 60 * 60;
score_beg = round(score_beg * info.fsample) / info.fsample;
%-----------------%

%-----------------%
%-create output score structure
score = struct();
score.marker = [];
score.rater = rater;
score.score_beg = score_beg;
score.wndw = epoch_dur;
score.stage = cell(1, 1);
%-----------------%

%-----------------%
%-loop over epochs
i = 1;
TOL = 1 / 24 / 3600;
while 1  % read until the end of the file
  
  epoch_datetime = get_epoch_datetime(s_epoch, str_recdate);
  
  % make sure htat epochs are consecutive
  assert(epoch_datetime - first_epoch_datetime - (i - 1) * epoch_dur / 24 / 3600 < TOL, 'Epochs are not consecutive')
  
  somno_score = strtrim(s_epoch(tabs(3):tabs(4)));
  score.stage{1, i} = convert_stage_names(somno_score);
  
  s_epoch = fgetl(fid);
  if s_epoch == -1
    break
  end
  tabs = strfind(s_epoch, sprintf('\t'));
  i = i + 1;
end
%-----------------%

%-----------------%
%-make sure that #epochs are not more than #epochs in recordings

% info taken from the recordings
score_beg = 1 / info.fsample;
score_end = info.hdr.nSamples * info.hdr.nTrials / info.fsample;

actual_nepoch = floor((score_end - score_beg) / score.wndw);

% info taken from somnologica
nepoch = size(score.stage, 2);

if nepoch > actual_nepoch
  warning(['N Epochs in Somnologica: ' num2str(nepoch) ...
           ', N Epochs in recordings: ' num2str(actual_nepoch) ...
           ', dropping last ' num2str(nepoch - actual_nepoch) ' epochs'])
  nepoch = actual_nepoch;
end
%-----------------%

score.nepoch = nepoch;
score.score_end = score.score_beg + score.nepoch * score.wndw;


function epoch_datetime = get_epoch_datetime(s_epoch, str_recdate)
HH_THRESHOLD = 12;

tabs = strfind(s_epoch, sprintf('\t'));

epoch_time = strtrim(s_epoch(tabs(2):tabs(3)));
epoch_datetime = datenum([str_recdate ' ' epoch_time], 'dd-mm-yy HH:MM:SS');
if mod(epoch_datetime, 1) < (HH_THRESHOLD / 24)  % if epoch is before HH_THRESHOLD, then use next day
  epoch_datetime = epoch_datetime + 1;
end


function epoch_score = convert_stage_names(somno_score)
%CONVERT_STAGE_NAMES  convert stages from Somnologica to sleepscoring
switch somno_score
  case 'Wake'
    epoch_score = 'Wakefulness';
  case 'REM'
    epoch_score = 'REM';
  case 'S1'
    epoch_score = 'NREM 1';
  case 'S2'
    epoch_score = 'NREM 2';
  case 'S3'
    epoch_score = 'NREM 3';
  otherwise
    epoch_score = 'NOT SCORED';
end


