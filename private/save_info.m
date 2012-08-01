function save_info

info = getappdata(0, 'info');

if isfield(info, 'infofile')
  save(info.infofile, 'info')
end
