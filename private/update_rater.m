function update_rater(info)
%UPDATE_RATER update the rater dropdown menu
% It's a subfunction of cb_rater, but it's called by prepare_info_opt as
% well (in case, the info contains already a score)

%-----------------%
%-activate menu rater
m_rater = findobj('tag', 'uimenu_rater');
delete(get(m_rater, 'child'))
%-----------------%

%-----------------%
%-check if real data
if isempty(info.score{2,1})
  
  %-------%
  %-disable buttons
  set(m_rater, 'enable', 'off')
  set(findobj('label', 'Rename Rater'), 'enable', 'off')
  set(findobj('label', 'Copy Current Score'), 'enable', 'off')
  set(findobj('label', 'Delete Current Score'), 'enable', 'off')
  set(findobj('label', 'Score Statistics'), 'enable', 'off')
  set(findobj('tag', 'p_hypno'), 'Title', 'Recording')
  %-------%
  
  %-------%
  % delete popupmarker
  delete(findobj('tag', 'popupmarker'))
  delete(findobj('tag', 'popupscore'))
  %-------%
  
else
  
  %-------%
  %-enable buttons
  set(m_rater, 'enable', 'on')
  set(findobj('label', 'Rename Rater'), 'enable', 'on')
  set(findobj('label', 'Copy Current Score'), 'enable', 'on')
  set(findobj('label', 'Delete Current Score'), 'enable', 'on')
  set(findobj('label', 'Score Statistics'), 'enable', 'on')
  %-------%
  
  %-------%
  %-create children in menu
  for i = 1:size(info.score,2)
    
    h_m = uimenu(m_rater, 'label', info.score{2,i}, 'call', @cb_rater);
    
    if i == info.rater
      set(h_m, 'check', 'on')
      set(findobj('tag', 'p_hypno'), 'Title', ['Hypnogram: ' info.score{2,i}])
    end
    %-------%
  end
  %-----------------%
  
end
