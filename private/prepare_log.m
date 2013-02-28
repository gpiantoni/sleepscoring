function info = prepare_log(info, action)
%PREPARE_LOG write log with changes
% 
% Called by:
%  - cb_rater
%  - prepare_info
%  - score_retime
%  - sleepscoring>cb_closemain
%  - sleepscoring>cb_openinfo

%-------------------------------------%
%-read info
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

gitrepo = fullfile(fileparts(which('ft_defaults')), '.git');
[~, ft_ver] = system(['git --git-dir=' gitrepo ' log |  awk ''NR==1'' | awk ''{print $2}''']);
gitrepo = fullfile(fileparts(which('sleepscoring')), '.git');
[~, sleep_ver] = system(['git --git-dir=' gitrepo ' log |  awk ''NR==1'' | awk ''{print $2}''']);
%-----------------%

%-----------------%
%-write log
log = [log sprintf('---------------------------------------\n')]; % begin
log = [log datestr(now, 'yyyy-mm-dd HH:MM:SS') ' ' user];
log = [log sprintf('\n')];
log = [log ' fieldtrip: ' ft_ver ' sleep scoring: ' sleep_ver];
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-ACTION
switch action
  
  case 'newinfo'
    log = [log 'NEW DATASET: ' info.infofile ' based on ' info.dataset];
    
  case 'openinfo'
    log = [log 'OPEN DATASET: ' info.infofile ' based on ' info.dataset];
    
    %-----------------%
    %-sleep scoring
  case 'New Rater'
    log = [log 'NEW RATER: ' info.score(info.rater).rater];
    
  case 'Rename Rater'
    log = [log 'RENAME RATER: ' info.score(info.rater).rater]; % original name is not available
    
  case 'Copy Current Score'
    log = [log 'COPY RATER: ' info.score(info.rater).rater];

  case 'Merge Scores'
    log = [log 'MERGE RATERS INTO: ' info.score(info.rater).rater];
    
  case 'Delete Current Score'
    log = [log 'DELETE SCORE: N.A.']; % original name is not available
    
  case 'Import Score from FASST'
    log = [log 'IMPORTED SCORE FROM FAAST: N.A.'];
    %-----------------%
    
    %-----------------%
    %-changes in the score
  case 'score_backup'
    log = [log 'BACK UP SCORE' backup_score(info.score(info.rater))];
    
  case 'score_begin'
    log = [log 'NEW SCORE BEGINS AT ' sprintf('% 12.3f', info.score(info.rater).score_beg)];
    
  case 'score_end'
    log = [log 'NEW SCORE ENDS   AT ' sprintf('% 12.3f', info.score(info.rater).score_end)];
    %-----------------%
    
  case 'closeinfo'
    log = [log 'CLOSE DATASET'];
    
    %-----------------%
    %-rater name
  otherwise
    log = [log 'VIEW RATER: ' info.score(info.rater).rater];
    %-----------------%
    
end
%-------------------------------------%

%-------------------------------------%
%-final
log = [log sprintf('\n')]; % end

info.log = log;
%-------------------------------------%

%-------------------------------------%
function log = backup_score(score)

%-----------------%
%-general info
log = sprintf(' (%s on % 4d % 3ds epochs) % 12.3f - % 12.3f\n', ...
  score.rater, score.nepoch, score.wndw, score.score_beg, score.score_end);
%-----------------%

%-----------------%
%-actual scoring
str_score = sprintf(' %s', score.stage{:});
log = [log '        ' str_score];
%-----------------%

%-----------------%
%-markers
for m = 1:numel(score.marker)
  if ~isempty(score.marker.time)
    
    str_mrk = ['     ' score.marker(m).name];
    for i = 1:size(score.marker(m).time,1)
      str_mrk = [str_mrk sprintf('[%.3f-%.3f] ', score.marker(m).time(i,1), score.marker(m).time(i,2))];
    end
    log = [log sprintf('\n') str_mrk];
    
  end
end
%-----------------%
