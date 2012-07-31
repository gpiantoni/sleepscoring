function savecfg

cfg = getappdata(0, 'cfg');
if isfield(cfg, 'cfgfile')
  save(cfg.cfgfile, 'cfg')
end
