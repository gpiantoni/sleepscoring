function cb_currentpoint(h, eventdata)
%---------------------------------------------------------%
%-CB_CURRENTPOINT
%---------------------------------------------------------%

tag = get(gca, 'tag');
pos = get(gca, 'currentpoint');

if strcmp(tag, 'a_dat')
  
  %-------------------------------------%
  %-main data
  if strcmp(get(h,'SelectionType'),'normal')
    
    set(h, 'WindowButtonMotionFcn', {@cb_box, pos})
    set(h, 'WindowButtonUpFcn', @cb_wbup)
    
  else
    % when right clicking use as marker
    
  end
  %-------------------------------------%
  
elseif strcmp(tag, 'a_hypno')
  
  %-------------------------------------%
  %-hypnogram
  %-----------------%
  %-check that the point is within the limit
  xlim = get(gca, 'xlim');
  ylim = get(gca, 'ylim');
  if pos(2,1) >= xlim(1) && pos(2,1) <= xlim(2) && ...
      pos(2,2) >= ylim(1) && pos(2,2) <= ylim(2)
    
    cfg = getappdata(0, 'cfg');
    opt = getappdata(0, 'opt');
    pnt = pos(2,1);
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
%---------------------------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
%-------------------------------------%
%-callback: when mouse is moving
function cb_box(hObject, eventdata, pos1)
% TODO: this does not take into account the scaling

opt = getappdata(0, 'opt');
pos2 = get(gca, 'CurrentPoint');

delete(findobj('tag', 'Selecting'))

p_l(1) = line( [pos1(1,1), pos1(1,1)], [pos1(1,2), pos2(1,2)]);
p_l(2) = line( [pos1(1,1), pos2(1,1)], [pos1(1,2), pos1(1,2)]);
p_l(3) = line( [pos2(1,1), pos2(1,1)], [pos1(1,2), pos2(1,2)]);
p_l(4) = line( [pos1(1,1), pos2(1,1)], [pos2(1,2), pos2(1,2)]);
set(p_l, 'tag', 'Selecting', 'Color', 'k', 'LineWidth', 2)

seltxt = sprintf('%1.2f s\n%1.1f uV', ...
                abs(pos2(1,1) - pos1(1,1)), abs((pos2(1,2) - pos1(1,2)) * opt.ylim(2)));
p_txt = ft_plot_text(pos1(1,1), pos1(1,2), seltxt);
set(p_txt, 'tag', 'Selecting', 'BackgroundColor', [0 0 0], 'Color', [1 1 1])
%-------------------------------------%

%-------------------------------------%
function cb_wbup(h, eventdata)

if strcmp(get(h, 'SelectionType'), 'normal')
  
  delete(findobj('tag', 'Selecting'))
  set(h,'WindowButtonMotionFcn', '')
  set(h,'WindowButtonUpFcn', '')
  
end
%-------------------------------------%
%---------------------------------------------------------%