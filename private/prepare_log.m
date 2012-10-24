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