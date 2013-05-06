function merged = score_merge(score)
%SCORE_MERGE merge the scores of two separate raters
%
% Called by
%  - cb_rater

%---------------------------%
%-check consistency
if numel(unique([score.nepoch])) ~= 1 % same number of epochs
  error('the scores have different numbers of windows: %s', sprintf('% 2d', [score.nepoch]))
end

if numel(unique([score.wndw])) ~= 1 % same lenght of the window
  error('epochs have different lengths: %s', sprintf('% 2d', [score.wndw]))
end

if numel(unique([score.score_beg])) ~= 1
  error('The beginning markers are different: %s', sprintf('% 8.3f', [score.score_beg]))
end
if numel(unique([score.score_end])) ~= 1
  error('The end markers are different: %s', sprintf('% 8.3f', [score.score_end]))
end
%---------------------------%

%---------------------------%
%-create new, "merged" score
merged = [];
mergedname = ['merged' sprintf(' %s -', score.rater)];
merged.rater = mergedname(1:end-2);

merged.wndw = score(1).wndw;
merged.nepoch = score(1).nepoch;
merged.score_beg = score(1).score_beg;
merged.score_end = score(1).score_end;
merged.marker = score(1).marker;

%-----------------%
%-TODO: merge the markers
for i = 1:numel(score(1).marker)
  merged.marker(i).name = score(1).marker(i).name;
  merged.marker(i).time = [];
end
%-----------------%

%-----------------%
%-scores
s = cat(1,score.stage); % easier to work with
for i = 1:merged.nepoch
  merged.stage(i) = majority(s(:,i));
end
%-----------------%
%---------------------------%

end

function y = majority(x)
%MAJORITY get the mode, only if there is a clear winner

u = unique(x);
for i = 1:numel(u)
  c(i) = numel(find(strcmp(x, u{i})));
end

[s, i] = sort(c);
u = u(i); % reorder

if numel(s) == 1 || ...
    s(end-1) ~= s(end) % if there is a clear winner
  
  y = u(end);
  
else
  y = {[]};
  
end

end