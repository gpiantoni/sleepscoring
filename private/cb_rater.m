function cb_rater(h0, eventdata)
%CB_RATER deals with all the functions about scoring
%
% Called by
%  - sleepscoring

%-------------------------------------%
%-INFO about scores
info = getappdata(0, 'info');
score = info.score;
rater = info.rater;

%-----------------%
%-if it's empty, it's the dummy rater. You can't do scoring with this
if isempty(score{2,1})
  nrater = 0;
else
  nrater = size(score,2);
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-operation depends on button press
switch get(h0, 'label')
  
  case 'New Rater'
    
    %-----------------%
    %-prompt
    prompt = {'Rater Name' 'Window Duration'};
    name = 'Sleep Score Information';
    defaultanswer = {'' '30'};
    answer = inputdlg(prompt, name, 1, defaultanswer);
    if isempty(answer); return; end
    
    newrater = answer{1};
    wndw = textscan(answer{2}, '%f');
    wndw = wndw{1};
    %-----------------%
    
    %-----------------%
    %-update score
    newscore = score_create(info, newrater, wndw);
    score(nrater + 1) = newscore;
    rater = nrater + 1;
    %-----------------%
    
  case 'Rename Rater'
    
    %-----------------%
    %-prompt
    prompt = {'Rater Name'};
    name = 'Rename Rater Name';
    defaultanswer = score(rater).rater; % default is the current name
    answer = inputdlg(prompt, name, 1, defaultanswer);
    if isempty(answer); return; end
    
    score(2, rater) = answer(1);
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
    to_merge = score_merge_select(score(2,:));
    if isempty(to_merge)
      return
    end
    %-----------------%
    
    %-----------------%
    %-update score
    rater = nrater + 1;
    score(:, rater) = score_merge(score(:, logical(to_merge)));
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
    if numel(score) == 1 % only one, delete all scoring
      score = score_create(info, [], []);
      rater = 1;
    else
      score(:, rater) = [];
      rater = nrater - 1;
    end
    %-----------------%
    
  case 'Import Score from FASST' % to do
    
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
      newscore = D.other.CRC.score;
      nnewscore = size(newscore,2); % number of new scores
      
      score(:, (1:nnewscore) + nrater) = newscore(1:7,:);
      
      rater = nrater + 1;
    end
    %-----------------%
    
  otherwise
    
    %-----------------%
    % name of the rater, called by update_rater
    rater = find(strcmp({score.rater}, get(h0, 'label')));
    %-----------------%
    
end
%-------------------------------------%

%-------------------------------------%
%-update info
info.rater = rater;
info.score = score;
info = prepare_log( get(h0, 'label'), info);

setappdata(0, 'info', info)
save_info()
update_rater(info)
cb_readplotdata()
%-------------------------------------%

