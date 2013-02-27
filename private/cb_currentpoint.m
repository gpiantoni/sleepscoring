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
    
    
    popup_str = get(findobj('tag', 'popupmarker'), 'str');
    popup_val = get(findobj('tag', 'popupmarker'), 'val');
    if isempty(popup_str); return; end % no score
    
    popup = popup_str{popup_val};
    
    if numel(popup) > 13 && ...
        strcmp(popup(1:13), 'sleep scoring')
      
      score_retime(pos, popup)
      
    else
      
      %-----------------%
      %-check if mark already exists
      info = getappdata(0, 'info');
      mrktype = get_markertype;
      if isempty(info.score{mrktype,info.rater})
        posmrk = false;
      else
        posmrk = pos(1,1) >= info.score{mrktype,info.rater}(:,1) & pos(1,1) <= info.score{mrktype,info.rater}(:,2);
      end
      %-----------------%
      
      if any(posmrk)
        
        %-----------------%
        %-delete old mark if inside
        info.score{mrktype,info.rater}(posmrk,:) = [];
        setappdata(0, 'info', info);
        save_info()
        cb_plotdata()
        %-----------------%
        
      else
        %-----------------%
        %-make new mark
        set(h, 'WindowButtonMotionFcn', {@cb_range, pos})
        set(h, 'WindowButtonUpFcn', {@cb_marker, pos})
        %-----------------%
      end
      
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
    
    info = getappdata(0, 'info');
    opt = getappdata(0, 'opt');
    wndw = info.score{3,info.rater};
    beginsleep = info.score{4,info.rater}(1); 
    
    pnt = pos(2,1) - beginsleep;
    opt.epoch = round(pnt / wndw);
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
function cb_box(h0, eventdata, pos1)
% TODO: this does not take into account the scaling

opt = getappdata(0, 'opt');
pos2 = get(gca, 'CurrentPoint');

delete(findobj('tag', 'Selecting'))

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
function cb_wbup(h0, eventdata)

if strcmp(get(h0, 'SelectionType'), 'normal')
  
  delete(findobj('tag', 'Selecting'))
  set(h0,'WindowButtonMotionFcn', '')
  set(h0,'WindowButtonUpFcn', '')
  
  plot_fft()
end
%-------------------------------------%

%-------------------------------------%
%-callback: when mouse is moving
function cb_range(h0, eventdata, pos1)

opt = getappdata(0, 'opt');
pos2 = get(gca, 'CurrentPoint');

delete(findobj('tag', 'sel_marker'))

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
set(h_f, 'tag', 'sel_marker')
drawnow
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: when click is released
function cb_marker(h0, eventdata, pos1)

pos2 = get(gca, 'CurrentPoint');

delete(findobj('tag', 'sel_marker'))
set(h0,'WindowButtonMotionFcn', '')
set(h0,'WindowButtonUpFcn', '')

make_marker(pos1, pos2)
%-------------------------------------%
%---------------------------------------------------------%

%---------------------------------------------------------%
%-SUBFUNCTIONS
%-------------------------------------%
%-make marker as artifact or other
function make_marker(pos1, pos2)

info = getappdata(0, 'info');
mrktype = get_markertype;
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
if isempty(info.score{mrktype,info.rater})
  addbeg = false;
  addend = false;
  
else
  addbeg = newmrk(1) <= info.score{mrktype,info.rater}(:,1) & newmrk(2) >= info.score{mrktype,info.rater}(:,1);
  addend = newmrk(1) <= info.score{mrktype,info.rater}(:,2) & newmrk(2) >= info.score{mrktype,info.rater}(:,2);
  
end

if any(addbeg)
  info.score{mrktype,info.rater}(addbeg,1) = newmrk(1);
  
elseif any(addend)
  info.score{mrktype,info.rater}(addend,2) = newmrk(2);
  
else
  info.score{mrktype,info.rater} = [info.score{mrktype,info.rater}; newmrk];
  
end
%-----------------%

%-----------------%
%-save info and replot
setappdata(0, 'info', info);
save_info()
cb_plotdata()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-Get Marker type
function mrktype = get_markertype

mrk_h = findobj('tag', 'popupmarker');
mrk_str = get(mrk_h, 'str');
mrk_val = get(mrk_h, 'val');

opt = getappdata(0, 'opt');

mrktype = find(strcmp(opt.marker.name, mrk_str{mrk_val}));
mrktype = mrktype + 4; % row in FASST score
%-------------------------------------%
%---------------------------------------------------------%