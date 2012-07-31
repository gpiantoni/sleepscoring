function savecfg

cfg = getappdata(0, 'cfg');

if isfield(cfg, 'cfgname')
  
  if ~isempty(cfg.cfgname)
    save(cfg.cfgname, 'cfg')
  end
  
else
  
  warning('TODO: cfgname should always be in there')
  
end
