function save_info
%SAVE_INFO save dataset information, to be called after each modification

info = getappdata(0, 'info');

if isfield(info, 'infofile')

  fid = fopen(info.infofile, 'w');
  if fid ~= -1
    fclose(fid);
    save(info.infofile, 'info')
    
  else
    warning(['could not save ' info.infofile ', probably you don''t have write permissions'])
    
  end
  
end
