function merged = merge_score(score)

%---------------------------%
%-check consistency
if numel(unique(cellfun(@numel, score(1,:)))) ~= 1 % same number of epochs
  error('the scores have different numbers of windows: %s', sprintf('% 2d', cellfun(@numel, score(1,:))))
end

if numel(unique([score{3,:}])) ~= 1 % same lenght of the window
  error('epochs have different lengths: %s', sprintf('% 2d', [score{3,:}]))
end

bnd = cat(1,score{4,:}); % boundaries
if numel(unique(bnd(:,1))) ~= 1
  error('The beginning markers are different: %s', sprintf('% 8.3f', bnd(:,1)))
end
if numel(unique(bnd(:,2))) ~= 1
  error('The end markers are different: %s', sprintf('% 8.3f', bnd(:,2)))
end
%---------------------------%

%---------------------------%
%-create new, "merged" score
%-----------------%
%-scores
merged{1,1} = NaN(size(score{1,1}));

s = cat(1,score{1,:}); % all the scores, easier to work with
for i = 1:size(merged{1},2)
  merged{1}(i) = majority(s(:,i));
end
%-----------------%

%-----------------%
%-name
mergedname = ['merged' sprintf(' %s -', score{2,:})];
merged{2,1} = mergedname(1:end-2);
%-----------------%

%-----------------%
%-the rest
merged{3,1} = score{3,1};
merged{4,1} = score{4,1};
merged{5,1} = [];
merged{6,1} = [];
merged{7,1} = [];
%-----------------%
%---------------------------%

end

function y = majority(x)
%MAJORITY get the mode, only if there is a clear winner

u = unique(x);
c = histc(x, u); % count uniques

[s, i] = sort(c);
u = u(i); % reorder

if numel(s) == 1 || ...
    s(end-1) ~= s(end) % if there is a clear winner
  
  y = u(end);
  
else
  y = NaN;
  
end

end