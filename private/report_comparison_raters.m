function report_comparison_raters(score, stage)
%COMPARE_RATERS using Cohen's k and comparison of one-against-one

%---------------------------%
%-variable already in scorestatistics
tab = @(x,tab_size)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];
n_stage = numel(stage);
n_rater = size(score,2);

if n_rater == 1
  return
end
%---------------------------%

%-------------------------------------%
%-cohen's kappa
tab_size = 3;

%---------------------------%
%-subject X subject matrix
fprintf('\nInter-rater agreement (Cohen''s kappa)\n\n')

%-----------------%
%-name of the rater
fprintf('\t\t\t')
for r = 1:n_rater
  fprintf(tab(score{2,r}, tab_size))
end
fprintf('\n')
%-----------------%

for r1 = 1:n_rater
  fprintf(tab(score{2,r1}, tab_size))
  
  for r2 = 1:n_rater
    
    if r1 > r2
      
      if score{3,r1} == score{3,r2}
        fprintf('% 10.2f \t\t', kappa(score{1,r1}, score{1,r2}))
      else
        fprintf('  diff wndw\t\t') % different scoring windows
      end
      
    else
      fprintf('\t\t\t')
    end
    
  end
  fprintf('\n')
  
end
%---------------------------%

%---------------------------%
%-compare subjects one-against-one
tab_size = 2; % number of tabs for realignment

for r1 = 1:n_rater
  for r2 = r1+1:n_rater
    fprintf('\n---------------------------\n')
    fprintf('%s - %s\n', score{2,r1}, score{2,r2})
    
    if score{3,r1} == score{3,r2}
      
      score1 = score{1, r1};
      score2 = score{1, r2};
      stagecode = [stage.code];
      
      %-------%
      %-unique identifier, instead of nan
      betternan = max([stagecode]) + 1;
      score1(isnan(score1)) = betternan;
      score2(isnan(score2)) = betternan;
      stagecode(isnan(stagecode)) = betternan;
      %-------%
      
      %-----------------%
      %-matrix where each column corresponds to stage
      c = zeros(n_stage);
      for s1 = 1:n_stage
        for s2 = 1:n_stage
          c(s1,s2) = numel(find(score1 == stagecode(s1) & score2 == stagecode(s2)));
        end
      end
      %-----------------%
      
      %-----------------%
      %-plots
      %-------%
      %-column headers
      fprintf(tab('', tab_size))
      for s = 1:n_stage
        fprintf(tab(stage(s).label, tab_size))
      end
      fprintf('\n')
      %-------%
      
      %-------%
      %-body
      for s = 1:n_stage
        
        fprintf(tab(stage(s).label, tab_size))
        fprintf('% 8d\t', c(s,:))
        fprintf('\n')
        
      end
      %-------%
      %-----------------%
      
    else
      fprintf('Scoring window is different between two raters:\n%s % 3ds and %s % 3ds\n', ...
        score{2,r1}, score{3,r1}, score{2,r2}, score{3,r2})
      
    end
    
        
  end
  
end
fprintf('\n---------------------------\n')
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-SUBFUNCTIONS------------------------%
%-------------------------------------%

%-------------------------------------%
%-calculate cohen's kappa
function k = kappa(a, b)

s = unique([a b]); % unique stages (cells in the c matrix)
s(isnan(s)) = []; % no NaN, not scored epochs

c = zeros(numel(s));

for i1 = 1:numel(s)
  for i2 = 1:numel(s)
    c(i1,i2) = numel(find(a == s(i1) & b == s(i2)));
  end
end

p = c ./ sum(c(:)); % proportions
p_obs = sum(diag(p)); % observed probability
p_rand = sum(sum(p,1) .* sum(p,2)'); % random probability

k = (p_obs - p_rand) ./ (1 - p_rand);
%-------------------------------------%