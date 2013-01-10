function sel = select_merge_score(raters)
%SELECT_MERGE_SCORE GUI to select raters to merge (at least 2)
%
% It returns an index of the raters to merge. If empty, it was cancelled.

%-------------------------------------%
%-MAIN
%---------------------------%
%-viz properties
height_box = 50;
box_size = [500 50];
%---------------------------%

%---------------------------%
%-create figure and fix its size
h = figure('Menubar', 'none', 'name', 'Scores to Merge', 'numbertitle', 'off', ...
  'closerequestfcn', @cancel);

pos = get(h, 'pos');
set(h, 'pos', [pos(1:2) box_size(1) height_box * numel(raters) + height_box * 2])
%---------------------------%

%---------------------------%
%-uicontrol
%-----------------%
%-title
uicontrol(h, 'style', 'text', 'str', 'Choose the scores to merge (at least 2):', ...
  'fontsize', 16, ...
  'pos', [5 height_box * (numel(raters) + 1) box_size]);
%-----------------%

%-----------------%
%-raters
for i = 1:numel(raters)
  u(i) = uicontrol(h, ...
    'style','checkbox', 'Position',[5 height_box * (numel(raters) -i+1) box_size], ...
    'String', raters{i}, ...
    'call', @count_selection);
end
%-----------------%

%-----------------%
%-OK button
p = uicontrol(h, 'style', 'push', 'str', 'OK', 'enable', 'off', ...
  'fontsize', 16, ...
  'pos', [0 0 box_size], ...
  'call', @chooserater);
%-----------------%
%---------------------------%

uiwait
delete(h)
%-------------------------------------%

%-------------------------------------%
%-SUBFUNCTION
%---------------------------%
%-COUNT SELECTED BOX
  function count_selection(~, ~)
    
    %-----------------%
    %-check box
    val = 0;
    for iu = 1:numel(u)
      val = val + get(u(iu), 'value') ;
    end
    %-----------------%
    
    %-----------------%
    if val >= 2
      set(p, 'enable', 'on')
    else
      set(p, 'enable', 'off')
    end
    %-----------------%
    
  end
%---------------------------%

%---------------------------%
%-if OK was pressed
  function chooserater(~, ~)
    
    for iu = 1:numel(u)
      sel(1,iu) = get(u(iu), 'value') ;
    end
    
    uiresume
  end
%---------------------------%

%---------------------------%
%-if figure was cancelled
  function cancel(~, ~)
    sel = [];
    
    uiresume
  end
%---------------------------%
%-------------------------------------%

end
