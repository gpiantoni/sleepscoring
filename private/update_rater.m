function update_rater(h, eventdata)
%UPDATE_RATER: select another rater or create a new one

cfg = getappdata(0, 'cfg');
m_rater = findobj('tag', 'uimenu_rater');

if nargin > 0
  
  %-------------------------------------%
  %-modify rater (as callback)
  set(get(m_rater, 'child'), 'check', 'off')
  
  ratername = get(h, 'label');
  
  %-update uimenu
  set(findobj(m_rater, 'label', ratername), 'check', 'on')
   
  %-update cfg
  cfg.rater = find(strcmp(cfg.score(2,:), ratername));
  cfg.wndw = cfg.score{3, cfg.rater};
  
  setappdata(0, 'cfg', cfg)
  %-------------------------------------%
  
else
  
  %-------------------------------------%
  %-add a new rater
  set(m_rater, 'enable', 'on')
  delete(get(m_rater, 'child'))
  
  for i = 1:size(cfg.score,2)
    
    h_m = uimenu(m_rater, 'label', cfg.score{2,i}, 'call', @update_rater);
    
    if i == cfg.rater
      set(h_m, 'check', 'on')
    end
  end
  %-------------------------------------%
  
end
  
cb_plotdata()  
