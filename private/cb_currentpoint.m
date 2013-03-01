function cb_currentpoint(h, eventdata)
%CB_CURRENTPOINT detect position of current point and act
%
% Called by
%  - sleepscoring

h0 = get_parent_fig(h);
tag = get(gca, 'tag');
pos = get(gca, 'currentpoint');

if strcmp(tag, 'a_dat')
  
  %-------------------------------------%
  %-main data
  if strcmp(get(h, 'SelectionType'),'normal')
    
    set(h, 'WindowButtonMotionFcn', {@cb_box, pos})
    set(h, 'WindowButtonUpFcn', @cb_wbup)
    
  else
    
    popup_str = get(findobj(h0, 'tag', 'popupmarker'), 'str');
    if isempty(popup_str); return; end % no score
    
    %-----------------%
    %-check if mark already exists
    info = getappdata(h0, 'info');
    mrktype = get_markertype(h0);
    if isempty(info.score(info.rater).marker(mrktype))
      posmrk = false;
    else
      posmrk = pos(1,1) >= info.score{mrktype,info.rater}(:,1) & pos(1,1) <= info.score{mrktype,info.rater}(:,2);
    end
    %-----------------%
    
    if any(posmrk)
      
      %-----------------%
      %-delete old mark if inside
      info.score{mrktype,info.rater}(posmrk,:) = [];
      save_info(info)
      setappdata(h0, 'info', info);
      
      cb_plotdata(h0)
      %-----------------%
      
    else
      %-----------------%
      %-make new mark
      set(h, 'WindowButtonMotionFcn', {@cb_range, pos})
      set(h, 'WindowButtonUpFcn', {@cb_marker, pos})
      %-----------------%
    end
    
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
    
    info = getappdata(h0, 'info');
    opt = getappdata(h0, 'opt');
    wndw = info.score(info.rater).wndw;
    beginsleep = info.score(info.rater).score_beg;
    
    pnt = pos(2,1) - beginsleep;
    opt.epoch = round(pnt / wndw);
    setappdata(h0, 'opt', opt)
    
    cb_readplotdata(h0)
    
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
function cb_box(h0, eventdata, pos1)

opt = getappdata(h0, 'opt');
pos2 = get(gca, 'CurrentPoint');

delete(findobj(h0, 'tag', 'Selecting'))

%-----------------%
%-black line
p_l(1) = line( [pos1(1,1), pos1(1,1)], [pos1(1,2), pos2(1,2)]);
p_l(2) = line( [pos1(1,1), pos2(1,1)], [pos1(1,2), pos1(1,2)]);
p_l(3) = line( [pos2(1,1), pos2(1,1)], [pos1(1,2), pos2(1,2)]);
p_l(4) = line( [pos1(1,1), pos2(1,1)], [pos2(1,2), pos2(1,2)]);
set(p_l, 'tag', 'Selecting', 'Color', 'k', 'LineWidth', 2)
%-----------------%

%-----------------%
%-text
seltxt = sprintf('%1.2f s\n%1.1f uV', ...
  abs(pos2(1,1) - pos1(1,1)), abs((pos2(1,2) - pos1(1,2)) * opt.ylim(2)));
p_txt = ft_plot_text(pos1(1,1), pos1(1,2), seltxt);
set(p_txt, 'tag', 'Selecting', 'BackgroundColor', [0 0 0], 'Color', [1 1 1])

drawnow
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-when click is released
function cb_wbup(h, eventdata)

if strcmp(get(h, 'SelectionType'), 'normal')

  h0 = get_parent_fig(h);
  delete(findobj(h0, 'tag', 'Selecting'))
  set(h,'WindowButtonMotionFcn', '')
  set(h,'WindowButtonUpFcn', '')
  
end
%-------------------------------------%

%-------------------------------------%
%-callback: when mouse is moving
function cb_range(h, eventdata, pos1)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
pos2 = get(gca, 'CurrentPoint');

delete(findobj(h0, 'tag', 'sel_marker'))

%-----------------%
%-range on yaxis
yrange(1) = -1 * numel([opt.changrp.chan]) - 1;
yrange(2) = 0;
%-----------------%

%-----------------%
%-range
hold on
h_f = fill([pos1(1,1) pos1(1,1) pos2(1,1) pos2(1,1)], ...
  yrange([1 2 2 1]), opt.marker.selcolor);
set(h_f, 'tag', 'sel_marker', 'facealpha', .5)
drawnow
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: when click is released
function cb_marker(h, eventdata, pos1)

h0 = get_parent_fig(h);
pos2 = get(gca, 'CurrentPoint');

delete(findobj(h0, 'tag', 'sel_marker'))
set(h, 'WindowButtonMotionFcn', '')
set(h, 'WindowButtonUpFcn', '')

if abs(diff([pos1(1,1), pos2(1,1)])) > .05 % has to be at least 50ms long
  make_marker(h0, pos1, pos2)
end
%-------------------------------------%
%---------------------------------------------------------%

%---------------------------------------------------------%
%-SUBFUNCTIONS
%-------------------------------------%
%-make marker as artifact or other
function make_marker(h0, pos1, pos2)

info = getappdata(h0, 'info');
mrktype = get_markertype(h0);
newmrk = sort([pos1(1,1) pos2(1,1)]);

%-----------------%
%-marker within the scoring window
xlim = get(gca, 'xlim');
if newmrk(1) < xlim(1); newmrk(1) = xlim(1); end
if newmrk(2) > xlim(2); newmrk(2) = xlim(2); end
%-----------------%

%-----------------%
%-make windows longer if new marker includes part of older marker
% TODO: With this implementation, it's impossible to "connect" two existing marks and to make one bigger on both sides
if isempty(info.score(info.rater).marker(mrktype).time)
  addbeg = false;
  addend = false;
  
else
  addbeg = newmrk(1) <= info.score(info.rater).marker(mrktype).time(:,1) & newmrk(2) >= info.score(info.rater).marker(mrktype).time(:,1);
  addend = newmrk(1) <= info.score(info.rater).marker(mrktype).time(:,2) & newmrk(2) >= info.score(info.rater).marker(mrktype).time(:,2);
  
end

if any(addbeg)
  info.score(info.rater).marker(mrktype).time(addbeg,1) = newmrk(1);
  
elseif any(addend)
  info.score(info.rater).marker(mrktype).time(addend,2) = newmrk(2);
  
else
  info.score(info.rater).marker(mrktype).time = [info.score(info.rater).marker(mrktype).time; newmrk];
  
end
%-----------------%

%-----------------%
%-save info and replot
save_info(info)
setappdata(h0, 'info', info);

cb_plotdata(h0)
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-Get Marker type
function mrktype = get_markertype(h0)

mrk_h = findobj(h0, 'tag', 'popupmarker');
mrk_str = get(mrk_h, 'str');
mrk_val = get(mrk_h, 'val');

opt = getappdata(h0, 'opt');

mrktype = find(strcmp(opt.marker.name, mrk_str{mrk_val}));
%-------------------------------------%
%---------------------------------------------------------%