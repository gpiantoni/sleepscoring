function cb_shortcuts(h0, eventdata)
%SHORTCUTS
%
% k -> next epoch
% j -> previous epoch
% 0 to 9 -> sleep stage, depending on code

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

switch eventdata.Key
  
  case opt.short.next
    
    opt = getappdata(0, 'opt');
    opt.epoch = opt.epoch + 1;
    setappdata(0, 'opt', opt);
    
    cb_readplotdata()
    
  case opt.short.previous
    
    opt = getappdata(0, 'opt');
    opt.epoch = opt.epoch - 1;
    setappdata(0, 'opt', opt);
    
    cb_readplotdata()
    
  case {'1' '2' '3' '4' '5' '6' '7' '8' '9' '0'}
    
    scored = str2double(eventdata.Key);
    i_score = find([opt.stage.code] == scored);
    
    if ~isempty(i_score)
      cfg.score{1, cfg.rater}(opt.epoch) = opt.stage(i_score).code;
      savecfg()
    
      opt.epoch = opt.epoch + 1;
    
      setappdata(0, 'cfg', cfg)
      setappdata(0, 'opt', opt)
      cb_readplotdata()
      
    else
      fprintf('Button %s does not match any sleep stage (%s)\n', eventdata.Key, sprintf(' %d', [opt.stage.code]))
      
    end
    
end