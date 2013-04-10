function info = convert_score_cell2struct(info)
%CONVERT_SCORE_CELL2STRUCT convert from FASST format into more flexible structure format
%
% Called by
%  - prepare_info

%-----------------%
%-struct format already
if isempty(info.score) || isstruct(info.score)
  return
end
%-----------------%

%-------------------------------------%
%-convert score
fprintf('WARNING: Converting score format from cell to structure.\nOld scores are stored in info.score_old\n')

%-----------------%
%-rearrange structures and keep old score
score_old = info.score;
info.score_old = score_old;
%-----------------%

%-----------------%
%-load scoring rules
opt = prepare_opt(info.optfile);
stage = opt.stage;
%-----------------%

%-----------------%
%-create new score
score = [];
for r = 1:size(score_old,2) % loop over raters
  
  score(r).rater = score_old{2,r};
  score(r).wndw = score_old{3,r};
  score(r).nepoch = numel(score_old{1,r});
  score(r).score_beg = score_old{4,r}(1);
  score(r).score_end = score_old{4,r}(2);
  
  score(r).marker(1).name = 'movement';
  score(r).marker(1).time = score_old{5,r} / info.fsample; % from samples to ms
  score(r).marker(2).name = 'arousal';
  score(r).marker(2).time = score_old{6,r} / info.fsample; % from samples to ms
  score(r).marker(3).name = 'artifact';
  score(r).marker(3).time = score_old{7,r} / info.fsample; % from samples to ms
  
  score(r).stage = cell(1, score(r).nepoch);
  
  for s = 1:numel(stage)
    
    %-use workaround for stages
    if isnan(stage(s).code)
      score(r).stage(isnan(score_old{1,r})) = {stage(s).label};
    else
      score(r).stage(score_old{1,r} == stage(s).code) = {stage(s).label};
    end      
    
  end
  
  if any(cellfun(@isempty, score(r).stage))
    fprintf('Could not convert all the epochs\n')
  end
  
end
%-----------------%

info.score = score;
%-------------------------------------%