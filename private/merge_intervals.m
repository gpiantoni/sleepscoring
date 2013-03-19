function x = merge_intervals(x_in)
%MERGE_INTERVALS merge intervals depending on boundaries
%
% Called by:
%  - cb_currentpoint

x = sortrows(x_in);

i1 = 1;
n = size(x,1);
while i1 <= n % for-loop is not enough bc it can change shape
  
  i2 = i1 + 1;
  while i2 <= n
    
    if x(i1,2) > x(i2,1) % this is the only condition, because columns are sorted
      x(i1,1) = min([x(i1,1), x(i2,1)]);
      x(i1,2) = max([x(i1,2), x(i2,2)]);
      x(i2,:) = [];
      n = n - 1;
    end
    
    i2 = i2 + 1;
  end
  
  i1 = i1 + 1;
end

% keep on running the same function until it doesn't change
if size(x,1) == size(x_in,1)
  return
else
  x = merge_intervals(x);
end