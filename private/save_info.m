function save_info(info)
%SAVE_INFO save dataset information, to be called after each modification
%
% Called by:
%  - cb_newinfo
%  - cb_rater
%  - cb_shortcuts
%  - score_popup>cb_score
%  - sleepscoring
%  - sleepscoring>cb_openinfo
%  - sleepscoring>cb_closemain

%-----------------%
%-save to file
if isfield(info, 'infofile')

  fid = fopen(info.infofile, 'w');
  if fid ~= -1
    fclose(fid);
    save(info.infofile, 'info')
    [~, username] = system(['stat -c %U ' info.infofile]);
    if strcmp(getenv('USER'), username)
      system(['chmod a+rw ' info.infofile]);
    end
    
  else
    warndlg(['could not save ' info.infofile ', probably you don''t have write permissions'], 'problems saving score')
    
  end
  
end
%-----------------%