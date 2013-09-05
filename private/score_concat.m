function out = score_concat(varargin)
%SCORE_CONCAT concatenate in time the scores
% It concatenates the epochs using the same scheme to divide up the epochs.
% Therefore, it should be expected that there is some difference between
% the window that was scored and the window which is used for the
% calculation. This difference should never be larger than the length of
% the window. This difference is not taken into account when the score
% statistics are calculated.
% 
% The absolute timing of the markers is not correct (but the duration is
% correct), so that the sleep statistics for the markers are correct.
% 
% Called by
%  - scorestatistics
%  - scorewriting

%-------------------------------------%
%-check input
%-----------------%
%-cell2struct
for i = 1:nargin
  info(i) = varargin{i};
end
%-----------------%

%-----------------%
%-order by time
[~, s] = sort([info.beginrec]);
info = info(s);
%-----------------%

%-----------------%
%-max distance
if diff([info.beginrec]) > 1
  error('The time difference between recordings is more than one day')
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-create output variable
% only keep fields that are used later on
out.dataset = sprintf('%s; ', info.dataset);
out.dataset = out.dataset(1:end-2);
out.infofile = sprintf('%s; ', info.infofile);
out.infofile = out.infofile(1:end-2);

out.beginrec = info(1).beginrec; % first recording
out.optfile = info(1).optfile; % take one as example

%-----------------%
%-check raters that are common to all the datasets
raters = {info(1).score.rater};
for r = 2:numel(info)
  raters = intersect(raters, {info(r).score.rater});
end

if numel(raters) > 1; S = 's'; else S = ''; end
fprintf('Found %d rater%s in all the datasets: %s\n', ...
  numel(raters), S, sprintf(' %s ', raters{:}))
%-----------------%

%---------------------------%
out.score = [];

for r = 1:numel(raters)
  
  %-----------------%
  %-name and index of the rater
  out.score(r).rater = raters{r};
  fprintf('\nRATER: %s\n', out.score(r).rater)
  
  i_r = [];
  for i = 1:numel(info)
    i_r(i) = find(strcmp({info(i).score.rater}, raters{r})); % index of the rater
  end
  %-----------------%
  
  %-----------------%
  %-windows length
  wndw = [];
  for i = 1:numel(info)
    wndw(i) = info(i).score(i_r(i)).wndw;
  end
  
  if numel(unique(wndw)) ~= 1
    error('Scoring window length is different (%s), cannot merge the files', ...
      sprintf(' %ds', wndw));
  end
  out.score(r).wndw = wndw(1);
  %-----------------%
  
  %-----------------%
  %-calculate begin and end 
  rec_begin = info(1).score(i_r(1)).score_beg;
  rec_diff = (info(end).beginrec - info(1).beginrec) * 24 * 60 * 60; % difference between beginning of first and last recording, in s
  rec_end = rec_diff + info(end).score(i_r(end)).score_end; % add the duration of the last recording
  
  out.score(r).score_beg = rec_begin;
  out.score(r).score_end = rec_end;
  %-----------------%
  
  %-----------------%
  %-markers 
  marker = {};
  for i = 1:numel(info)
    marker = union(marker, {info(i).score(i_r(i)).marker.name});
  end
  
  for m = 1:numel(marker)
    out.score(r).marker(m).name = marker{m};
    out.score(r).marker(m).time = [];
    for i = 1:numel(info)
      i_m = find(strcmp({info(i).score(i_r(i)).marker.name}, marker{m}));
      out.score(r).marker(m).time = [out.score(r).marker(m).time; 
                                     info(i).score(i_r(i)).marker(i_m).time];
    end
  end
  %-----------------%
  
  %-----------------%
  n_epochs = ceil((out.score(r).score_end - out.score(r).score_beg) / wndw(1) );
  out.score(r).stage = cell(1, n_epochs);
  
  rec_begin_abs = info(1).score(i_r(1)).score_beg + info(1).beginrec;
  for i = 1:numel(info)
    info_begin_abs = info(i).score(i_r(i)).score_beg + info(i).beginrec;
    diff_begin = (info_begin_abs - rec_begin_abs) * 24 * 60 * 60;
    
    %-------%
    %-get first epoch
    diff_epoch = diff_begin / wndw(1);
    mod_epoch = mod(diff_begin, wndw(1));
    fprintf('Distance between epoch beginning and sleep scoring window is % 6.3f\n', ...
      mod_epoch)
    diff_epoch = round(diff_epoch);
    %-------%
    
    n_scored = numel(info(i).score(i_r(i)).stage);
    
    out.score(r).stage(1, diff_epoch + (1:n_scored)) = info(i).score(i_r(i)).stage;
    
  end
  %-----------------%
  
end
%---------------------------%

if numel(raters) > 1
  fprintf('\nWarning: after scores merging, the order of the raters might be different\n\n')
end
%-------------------------------------%
