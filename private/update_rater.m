function update_rater(info, h)
%UPDATE_RATER update the rater dropdown menu
% It's a subfunction of cb_rater, but it's called by prepare_info_opt as
% well (in case, the info contains already a score)
%
% Called by
%  - cb_rater
%  - prepare_info_opt

%-----------------%
%-activate menu rater
delete(get(h.menu.score.rater, 'child'))
%-----------------%

%-----------------%
%-check if real data
if isempty(info.score(info.rater).rater)
  
  %-------%
  %-disable buttons
  set(h.menu.score.rater, 'enable', 'off')
  set(h.menu.score.rename, 'enable', 'off')
  set(h.menu.score.copy, 'enable', 'off')
  set(h.menu.score.merge, 'enable', 'off')
  set(h.menu.score.delete, 'enable', 'off')
  set(h.menu.score.statistics, 'enable', 'off')
  set(h.panel.hypno.h, 'Title', 'Recording')
  %-------%
  
  %-------%
  % delete popupmarker
  delete(h.panel.info.popupscore)
  delete(h.panel.info.popupmarker)
  %-------%
  
else
  
  %-------%
  %-enable buttons
  set(h.menu.score.rater, 'enable', 'on')
  set(h.menu.score.rename, 'enable', 'on')
  set(h.menu.score.copy, 'enable', 'on')
  set(h.menu.score.merge, 'enable', 'on')
  set(h.menu.score.delete, 'enable', 'on')
  set(h.menu.score.statistics, 'enable', 'on')
  %-------%
  
  %-------%
  %-create children in menu
  for i = 1:size(info.score,2)
    
    h_m = uimenu(h.menu.score.rater, 'label', info.score(i).rater, 'call', @cb_rater);
    
    if i == info.rater
      set(h_m, 'check', 'on')
      set(h.panel.hypno.h, 'Title', ['Hypnogram: ' info.score(i).rater])
    end
    %-------%
  end
  %-----------------%
  
end
