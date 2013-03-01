function cb_shortcuts(h, eventdata)
%SHORTCUTS
%
% opt.short.next -> next epoch
% opt.short.previous -> previous epoch
% 0 to 9 -> sleep stage, depending on code
%
% Called by
%  - sleepscoring

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

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
    
  case {'1' '2' '3' '4' '5' '6' '7' '8' '9' '0'}
    
    if ~isempty(info.score(info.rater).rater) % no scoring without score sheet
      %-----------------%
      %-sleep scoring
      scored = str2double(eventdata.Key);
      i_score = find([opt.stage.shortcut] == scored);
      
      if ~isempty(i_score)
        info.score{1, info.rater}(opt.epoch) = opt.stage(i_score).code;
        save_info(info)
        
        opt.epoch = opt.epoch + 1;
        
        setappdata(h0, 'info', info)
        setappdata(h0, 'opt', opt)
        
        cb_readplotdata(h0)
        
      else
        fprintf('Button %s does not match any sleep stage (%s)\n', eventdata.Key, sprintf(' %d', [opt.stage.code]))
        
      end
      %-----------------%
    end
    
end