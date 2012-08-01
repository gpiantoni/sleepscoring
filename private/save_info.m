function save_info
%SAVE_INFO save dataset information, to be called after each modification

info = getappdata(0, 'info');

if isfield(info, 'infofile')
  save(info.infofile, 'info')
end
