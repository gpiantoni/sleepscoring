function cb_shortcuts(h, eventdata)
%SHORTCUTS
%
% opt.short.next -> next epoch
% opt.short.previous -> previous epoch
% 0 to 9 -> sleep stage, depending on code
%
% Called by
%  - create_handles

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

%-----------------%
%-don't call shortcuts if user edits the epoch number or the y lim
if h == opt.h.panel.info.epoch || ...
    h == opt.h.panel.info.ylimval
  return
end
%-----------------%

switch eventdata.Key
  
  case opt.short.next
    %-----------------%
    %-next epoch
    opt = getappdata(h0, 'opt');
    opt.epoch = opt.epoch + 1;
    setappdata(h0, 'opt', opt);
    
    cb_readplotdata(h0)
    %-----------------%
    
  case opt.short.previous
    %-----------------%
    %-previous epoch
    opt = getappdata(h0, 'opt');
    opt.epoch = opt.epoch - 1;
    setappdata(h0, 'opt', opt);
    
    cb_readplotdata(h0)
    %-----------------%
    
  case {opt.stage.shortcut}
    
    if ~isempty(info.score(info.rater).rater) % no scoring without score sheet
      
      %-----------------%
      %-sleep scoring
      i_score = find(strcmp({opt.stage.shortcut}, eventdata.Key));
      
      if ~isempty(i_score)
        info.score(info.rater).stage{opt.epoch} = opt.stage(i_score).label;
        save_info(info)
        
        opt.epoch = opt.epoch + 1;
        
        setappdata(h0, 'info', info)
        setappdata(h0, 'opt', opt)
        
        cb_readplotdata(h0)
        
      else
        fprintf('Button %s does not match any sleep stage (%s)\n', eventdata.Key, sprintf(' ''%s''', opt.stage.shortcut))
        
      end
      %-----------------%
    end
    
end