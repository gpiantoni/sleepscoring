function out = score_concat(varargin)
%SCORE_CONCAT concatenate in time the scores
%
% Called by
%  - scorestatistics
%  - scorewriting

error(sprintf('Sorry, this function has not be implemented yet for the struct format of the score\nPlease, contact gio@gpiantoni.com'))

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
  error('the time difference between recordings is more than one day')
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-create output variable
% only keep fields that are used later on
out.beginrec = info(1).beginrec; % first recording
out.optfile = info(1).optfile; % take one as example

%-----------------%
%-check raters that are common to all the datasets
raters = info(1).score(2,:);
for r = 2:numel(info)
  raters = intersect(raters, info(r).score(2,:));
end
%-----------------%

%---------------------------%
out.score = [];

for r = 1:numel(raters)
  
  %-----------------%
  %-name and index of the rater
  out.score{2,r} = raters{r};
  
  for i = 1:numel(info)
    i_r(i) = find(strcmp(info(i).score(2,:), raters{r})); % index of the rater
  end
  %-----------------%
  
  out.score{3,r} = info(1).score{3, i_r(1)}; % assume they all use the same scoring window

  %-----------------%
  %-calculate begin and end 
  rec_begin = info(1).score{4, i_r(1)}(1);
  rec_diff = (info(end).beginrec - info(1).beginrec) * 24 * 60 * 60; % difference between beginning of first and last recording, in s
  rec_end = rec_diff + info(end).score{4, i_r(end)}(2); % add the duration of the last recording
  
  out.score{4,r} = [rec_begin rec_end];
  %-----------------%
  
  %-----------------%
  %-other info (TODO if necessary)
  out.score{5,r} = [];
  out.score{6,r} = [];
  out.score{7,r} = [];
  %-----------------%
  
  %-----------------%
  n_epochs = ceil( diff(out.score{4,r}) / 30 );
  out.score{1,r} = NaN(1, n_epochs);
  
  rec_begin_abs = info(1).score{4, i_r(1)}(1) + info(1).beginrec;
  for i = 1:numel(info)
    info_begin_abs = info(i).score{4, i_r(i)}(1) + info(i).beginrec;
    diff_begin = (info_begin_abs - rec_begin_abs) * 24 * 60 * 60;
    
    %-------%
    %-get first epoch
    diff_epoch = diff_begin / out.score{3,r};
    mod_epoch = mod(diff_begin, out.score{3,r});
    fprintf('Distance between epoch beginning and sleep scoring window is % 6.3f\n', ...
      mod_epoch)
    diff_epoch = round(diff_epoch);
    %-------%
    
    n_scored = numel(info(i).score{1,i_r(i)});
    
    out.score{1,r}(1, diff_epoch + (1:n_scored)) = info(i).score{1, i_r(i)};
    
  end
  %-----------------%
  
end

%---------------------------%
%-------------------------------------%
