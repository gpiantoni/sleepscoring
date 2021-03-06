function cb_rater(h, eventdata)
%CB_RATER deals with all the functions about scoring
%
% Called by
%  - sleepscoring

%-------------------------------------%
%-INFO about scores
h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
score = info.score;
rater = info.rater;

%-----------------%
%-if it's empty, it's the dummy rater. You can't do scoring with this
if isempty(score(rater).rater)
  nrater = 0;
else
  nrater = size(score,2);
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-operation depends on button press
switch get(h, 'label')
  
  case 'New Rater'
    
    %-----------------%
    %-prompt
    prompt = {'Rater Name' 'Window Duration'};
    name = 'Sleep Score Information';
    defaultanswer = {'' '30'};
    answer = inputdlg(prompt, name, 1, defaultanswer);
    if isempty(answer); return; end
    
    newrater = answer{1};
    %-input validation
    if isempty(newrater);
      warning('Name of the rater cannot be empty')
      return
    end
    
    if any(strcmp({score.rater}, newrater))
      warning('This rater''s name exists already')
      return
    end
    
    wndw = textscan(answer{2}, '%f');
    wndw = wndw{1};
    %-----------------%
    
    %-----------------%
    %-update score
    newscore = score_create(info, newrater, wndw);
    if numel(score) == 1 && isempty(score(1).rater)
      score = newscore;
    else
      score = [score newscore];
    end
    rater = nrater + 1;
    %-----------------%
    
    %-----------------%
    %-add default markers
    opt = getappdata(h0, 'opt');
    for i = 1:numel(opt.marker.name)
      score(rater).marker(i).name = opt.marker.name{i};
      score(rater).marker(i).time = [];
    end
    %-----------------%
    
  case 'Rename Rater'
    
    %-----------------%
    %-prompt
    prompt = {'Rater Name'};
    name = 'Rename Rater Name';
    defaultanswer = {score(rater).rater}; % default is the current name
    answer = inputdlg(prompt, name, 1, defaultanswer);
    if isempty(answer); return; end
    
    score(rater).rater = answer{1};
    %-----------------%
    
  case 'Copy Current Score'
    
    %-----------------%
    %-update score
    score(nrater + 1) = score(rater);
    score(nrater + 1).rater = [score(rater).rater ' (copy)'];
    
    rater = nrater + 1;
    %-----------------%
    
  case 'Merge Scores'
    
    %-----------------%
    %-prompt
    to_merge = score_merge_select({score.rater});
    if isempty(to_merge)
      return
    end
    %-----------------%
    
    %-----------------%
    %-update score
    rater = nrater + 1;
    score = [score score_merge(score(logical(to_merge)))];
    %-----------------%
    
  case 'Import Score from FASST'
    
    %-----------------%
    %-prompt
    [filename, pathname] = uigetfile('*.mat', 'Select FASST file');
    if ~filename; return; end
    warning off % class to struct warning
    load([pathname filename], 'D')
    warning on
    %-----------------%
    
    %-----------------%
    %-merge the scores
    if isfield(D.other, 'CRC') && isfield(D.other.CRC, 'score')
      info_fasst = info;
      info_fasst.score = D.other.CRC.score;
      info_fasst = convert_score_cell2struct(info_fasst);
      if numel(score) == 1 && isempty(score(1).rater)
        score = info_fasst.score;
      else
        score = [score info_fasst.score];
      end
      
      rater = nrater + 1;
    end
    %-----------------%
    
  case 'Import Score from Somnologica'
    
    %-----------------%
    %-prompt
    [filename, pathname] = uigetfile('*Events.txt', 'Select Somnologica Events file');
    if ~filename; return; end
    somno_score = import_somnologica([pathname filename], info);
    %-----------------%
    
    %-----------------%
    %-merge the scores
    if numel(score) == 1 && isempty(score(1).rater)
      score = somno_score;
    else
      score = [score somno_score];
    end
    
    rater = nrater + 1;
    %-----------------%
    
  case 'Delete Current Score'
    
    %-----------------%
    ConfirmDel = questdlg('Are you sure that you want to delete the current score?', ...
      'Delete Current Score', ...
      'Yes', 'No', 'Yes');
    if strcmp(ConfirmDel, 'No'); return; end
    %-----------------%
    
    %-----------------%
    %-update score
    info = prepare_log(info, 'score_backup'); % to tests
    
    if numel(score) == 1 % only one, delete all scoring
      score = score_create(info, [], []);
      rater = 1;
    else
      score(rater) = [];
      rater = nrater - 1;
    end
    %-----------------%
    
  otherwise
    
    %-----------------%
    % name of the rater, called by update_rater
    rater = find(strcmp({score.rater}, get(h, 'label')));
    %-----------------%
    
end
%-------------------------------------%

%-------------------------------------%
%-update info
info.rater = rater;
info.score = score;
info = prepare_log(info, get(h, 'label'));

save_info(info)
setappdata(h0, 'info', info)

opt = getappdata(h0, 'opt');

update_rater(info, opt)
cb_readplotdata(h0)
%-------------------------------------%

