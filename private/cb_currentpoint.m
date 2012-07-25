function cb_currentpoint(h, eventdata)

tag = get(gca, 'tag');
pnt = get(gca, 'currentpoint');

if strcmp(tag, 'a_dat') % main data axis
  
  
elseif strcmp(tag, 'a_hypno') % hypnogram
%-------------------------------------%
  
%-----------------%
%-check that the point is within the limit
xlim = get(gca, 'xlim');
  ylim = get(gca, 'ylim');
  if pnt(2,1) >= xlim(1) && pnt(2,1) <= xlim(2) && ...
      pnt(2,2) >= ylim(1) && pnt(2,2) <= ylim(2)
  
    cfg = getappdata(0, 'cfg');
    opt = getappdata(0, 'opt');
    pnt = pnt(2,1);
    opt.epoch = round(pnt / cfg.wndw);
    
    %-TODO: the timing should be based on epoch/score info
    opt.begsample = (opt.epoch-1) * cfg.wndw * cfg.hdr.Fs + 1;
    opt.endsample = opt.begsample + cfg.hdr.Fs * cfg.wndw - 1;
    setappdata(0, 'opt', opt)
    
    cb_readplotdata()
  
  end
  %-----------------%
  
  
  %-------------------------------------%
end


