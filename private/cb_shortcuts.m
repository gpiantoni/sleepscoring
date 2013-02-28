function cb_shortcuts(h0, eventdata)
%SHORTCUTS
%
% opt.short.next -> next epoch
% opt.short.previous -> previous epoch
% 0 to 9 -> sleep stage, depending on code
%
% Called by
%  - sleepscoring

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

switch eventdata.Key
  
  case opt.short.next
    %-----------------%
    %-next epoch
    opt = getappdata(0, 'opt');
    opt.epoch = opt.epoch + 1;
    setappdata(0, 'opt', opt);
    
    cb_readplotdata()
    %-----------------%
    
  case opt.short.previous
    %-----------------%
    %-previous epoch
    opt = getappdata(0, 'opt');
    opt.epoch = opt.epoch - 1;
    setappdata(0, 'opt', opt);
    
    cb_readplotdata()
    %-----------------%
    
  case {'1' '2' '3' '4' '5' '6' '7' '8' '9' '0'}
    
    if ~isempty(info.score{2,1}) % no scoring without score sheet
      %-----------------%
      %-sleep scoring
      scored = str2double(eventdata.Key);
      i_score = find([opt.stage.code] == scored);
      
      if ~isempty(i_score)
        info.score{1, info.rater}(opt.epoch) = opt.stage(i_score).code;
        save_info()
        
        opt.epoch = opt.epoch + 1;
        
        setappdata(0, 'info', info)
        setappdata(0, 'opt', opt)
        cb_readplotdata()
        
      else
        fprintf('Button %s does not match any sleep stage (%s)\n', eventdata.Key, sprintf(' %d', [opt.stage.code]))
        
      end
      %-----------------%
    end
    
end