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

%---------------------------%
%-remove not-score at the beginning and at the end
% they indicate lights-off and lights-on
for r = 1:n_rater
  
  i_nan = find(~strcmp(score(r).stage, stage(1).label), 1) - 1;
  score(r).stage(1:i_nan) = deal({''});

  i_nan = find(~strcmp(score(r).stage, stage(1).label), 1, 'last') + 1;
  score(r).stage(i_nan:end) = deal({''});

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
  fprintf(tab(score(r).rater, tab_size))
end
fprintf('\n')
%-----------------%

c = cell(n_rater);
for r1 = 1:n_rater
  fprintf(tab(score(r1).rater, tab_size))
  
  for r2 = 1:n_rater
    
    if r1 < r2
      
      if score(r1).score_beg == score(r2).score_beg && ...
          score(r1).wndw == score(r2).wndw

        fprintf('% 8.2f \t\t', kappa(score(r1).stage, score(r2).stage))
        
      else
        fprintf('  diff wndw\t\t') % different scoring windows
        
      end
      
    else
      fprintf('    -\t\t\t')
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
    fprintf('%s - %s\n', score(r1).rater, score(r2).rater)
    
    if score(r1).wndw ~= score(r2).wndw
      fprintf('Scoring window is different between two raters:\n%s % 3ds and %s % 3ds\n', ...
        score(r1).rater, score(r1).wndw, score(r2).rater, score(r2).wndw)
      
    elseif score(r1).score_beg ~= score(r2).score_beg 
      fprintf('Beginning of the score is different between two raters:\n%s % 3ds and %s % 3ds\n', ...
        score(r1).rater, score(r1).score_beg, score(r2).rater, score(r2).score_beg)
      
    else
      
      %-----------------%
      %-matrix where each column corresponds to stage
      c = zeros(n_stage);
      for s1 = 1:n_stage
        for s2 = 1:n_stage
          c(s1,s2) = numel(find(strcmp(score(r1).stage, stage(s1).label) & strcmp(score(r2).stage, stage(s2).label)));
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
s = setdiff(s, {''}); % remove empty marker
c = zeros(numel(s));

for i1 = 1:numel(s)
  for i2 = 1:numel(s)
    c(i1,i2) = numel(find(strcmp(a, s(i1)) & strcmp(b, s(i2))));
  end
end

p = c ./ sum(c(:)); % proportions
p_obs = sum(diag(p)); % observed probability
p_rand = sum(sum(p,1) .* sum(p,2)'); % random probability

k = (p_obs - p_rand) ./ (1 - p_rand);
%-------------------------------------%