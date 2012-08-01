function cb_rater(h0, eventdata)
%CB_RATER deals with all the functions about scoring

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
    newscore = prepare_score(info, newrater, wndw);
    score(:, nrater + 1) = newscore;
    %-----------------%
    
  case 'Rename Rater'
    
    %-----------------%
    %-prompt
    prompt = {'Rater Name'};
    name = 'Rename Rater Name';
    defaultanswer = score(2, rater); % default is the current name
    answer = inputdlg(prompt, name, 1, defaultanswer);
    if isempty(answer); return; end
    
    score(2, rater) = answer(1);
    %-----------------%
    
  case 'Copy Current Score'
    
    %-----------------%
    %-update score
    score(:, nrater + 1) = score(:, rater);
    score{2, nrater + 1} = [score{2, rater} ' (copy)'];
    
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
    if size(score, 2) == 1 % only one, delete all scoring
      score = prepare_score(info);
      rater = 1;
    else
      score(:, rater) = [];
      rater = nrater - 1;
    end
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
      newscore = D.other.CRC.score;
      nnewscore = size(newscore,2); % number of new scores
      
      score(:, (1:nnewscore) + nrater) = newscore;
      
      rater = nrater + 1;
    end
    %-----------------%
    
  otherwise
    
    %-----------------%
    % name of the rater, called by update_rater
    rater = find(strcmp(score(2,:), get(h0, 'label')));
    %-----------------%
    
end
%-------------------------------------%

%-------------------------------------%
%-update info
info.rater = rater;
info.score = score;

save_info()
setappdata(0, 'info', info)
update_rater(info)
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-update rater
function update_rater(info)

%-----------------%
%-activate menu rater
m_rater = findobj('tag', 'uimenu_rater');
delete(get(m_rater, 'child'))
%-----------------%

%-----------------%
%-check if real data
if isempty(info.score{2,1})
  
  %-------%
  %-disable buttons
  set(m_rater, 'enable', 'off')
  set(findobj('label', 'Rename Rater'), 'enable', 'off')
  set(findobj('label', 'Copy Current Score'), 'enable', 'off')
  set(findobj('label', 'Delete Current Score'), 'enable', 'off')
  set(findobj('tag', 'p_hypno'), 'Title', 'Recording')
  %-------%
  
else
  
  %-------%
  %-disable buttons
  set(m_rater, 'enable', 'on')
  set(findobj('label', 'Rename Rater'), 'enable', 'on')
  set(findobj('label', 'Copy Current Score'), 'enable', 'on')
  set(findobj('label', 'Delete Current Score'), 'enable', 'on')
  %-------%
  
  %-------%
  %-create children in menu
  for i = 1:size(info.score,2)
    
    h_m = uimenu(m_rater, 'label', info.score{2,i}, 'call', @cb_rater);
    
    if i == info.rater
      set(h_m, 'check', 'on')
      set(findobj('tag', 'p_hypno'), 'Title', ['Hypnogram: ' info.score{2,i}])
    end
    %-------%
  end
  %-----------------%
  
end
%-------------------------------------%

