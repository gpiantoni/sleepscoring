function [varargout] = prepare_log(action, info)


%-------------------------------------%
%-read info
if nargin == 1
  info = getappdata(0, 'info');
end
if isfield(info, 'log')
  log = info.log;
else
  log = '';
end
%-------------------------------------%

%-------------------------------------%
%-general info
%-----------------%
%-get info
if (isunix)
  user = getenv('USER');
else
  user = getenv('username');
end

ft_ver = ft_version;
gitrepo = fullfile(fileparts(which('sleepscoring')), '.git');
[~, sleep_ver] = system(['git --git-dir=' gitrepo ' log |  awk ''NR==1'' | awk ''{print $2}''']);
%-----------------%

%-----------------%
%-write log
log = [log sprintf('---------------------------------------\n')]; % begin
log = [log datestr(now, 'yyyy-mm-dd HH:MM:SS') ' ' user];
log = [log sprintf('\n')];
log = [log ' fieldtrip: ' ft_ver ', sleep scoring: ' sleep_ver];
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-ACTION
switch action
  
  case 'cb_newinfo'
    log = [log 'NEW DATASET: ' info.infofile ' based on ' info.dataset];
    
  case 'cb_openinfo'
    log = [log 'OPEN DATASET: ' info.infofile ' based on ' info.dataset];
    
    %-----------------%
    %-sleep scoring
  case 'New Rater'
    log = [log 'NEW RATER: ' info.score{2,info.rater}];
    
  case 'Rename Rater'
    log = [log 'RENAME RATER: ' info.score{2,info.rater}]; % original name is not available
    
  case 'Copy Current Score'
    log = [log 'COPY RATER: ' info.score{2,info.rater}];
    
  case 'Delete Current Score'
    log = [log 'DELETE SCORE: N.A.']; % original name is not available
    
  case 'Import Score from FASST'
    log = [log 'IMPORTED SCORE FROM FAAST: N.A.'];
    %-----------------%
    
    %-----------------%
    %-changes in the score
  case 'score_backup'
    log = [log 'BACK UP SCORE' backup_score(info.score(:,info.rater))];
    
  case 'score_begin'
    log = [log 'NEW SCORE BEGINS AT ' sprintf('% 12.3f', info.score{4,info.rater}(1))];
    
  case 'score_end'
    log = [log 'NEW SCORE ENDS   AT ' sprintf('% 12.3f', info.score{4,info.rater}(2))];
    %-----------------%
    
  case 'cb_closemain'
    log = [log 'CLOSE DATASET'];
    
    %-----------------%
    %-rater name
  otherwise
    log = [log 'VIEW RATER: ' info.score{2,info.rater}];
    %-----------------%
    
end
%-------------------------------------%

%-------------------------------------%
%-final
log = [log sprintf('\n---------------------------------------\n')]; % end

info.log = log;
if nargout == 0
  setappdata(0, 'info', info);
else
  varargout{1} = info;
end
%-------------------------------------%

%-------------------------------------%
function log = backup_score(score)

%-----------------%
%-general info
log = sprintf(' (%s on % 4d % 3ds epochs) % 12.3f - % 12.3f\n', ...
  score{2,1}, numel(score{1,1}), score{3,1}, score{4,1}(1), score{4,1}(2));
%-----------------%

%-----------------%
%-actual scoring
str_score = sprintf(' % 3d', score{1,1});
log = [log '        ' str_score];
%-----------------%

%-----------------%
%-artifacts
str_art = '     art ';
for i = 1:size(score{5,1},1)
  str_art = [str_art sprintf('[%.3f-%.3f] ', score{5,1}(i,1), score{5,1}(i,2))];
end
log = [log sprintf('\n') str_art];
%-----------------%

%-----------------%
%-movements
str_move = '     move ';
for i = 1:size(score{6,1},1)
  str_move = [str_move sprintf('[%.3f-%.3f] ', score{6,1}(i,1), score{6,1}(i,2))];
end
log = [log sprintf('\n') str_move];
%-----------------%

%-----------------%
%-arousals
if size(score,1) > 6
  str_arou = '     arou ';
  for i = 1:size(score{7,1},1)
    str_arou = [str_arou sprintf('[%.3f-%.3f] ', score{7,1}(i,1), score{7,1}(i,2))];
  end
  log = [log sprintf('\n') str_arou];
end
%-----------------%