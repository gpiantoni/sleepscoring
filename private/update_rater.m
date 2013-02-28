function update_rater(h0, info)
%UPDATE_RATER update the rater dropdown menu
% It's a subfunction of cb_rater, but it's called by prepare_info_opt as
% well (in case, the info contains already a score)
%
% Called by
%  - cb_rater
%  - prepare_info_opt

%-----------------%
%-activate menu rater
m_rater = findobj(h0, 'tag', 'uimenu_rater');
delete(get(m_rater, 'child'))
%-----------------%

%-----------------%
%-check if real data
if isempty(info.score(info.rater).rater)
  
  %-------%
  %-disable buttons
  set(m_rater, 'enable', 'off')
  set(findobj(h0, 'label', 'Rename Rater'), 'enable', 'off')
  set(findobj(h0, 'label', 'Copy Current Score'), 'enable', 'off')
  set(findobj(h0, 'label', 'Merge Scores'), 'enable', 'off')
  set(findobj(h0, 'label', 'Delete Current Score'), 'enable', 'off')
  set(findobj(h0, 'label', 'Score Statistics'), 'enable', 'off')
  set(findobj(h0, 'tag', 'p_hypno'), 'Title', 'Recording')
  %-------%
  
  %-------%
  % delete popupmarker
  delete(findobj(h0, 'tag', 'popupmarker'))
  delete(findobj(h0, 'tag', 'popupscore'))
  %-------%
  
else
  
  %-------%
  %-enable buttons
  set(m_rater, 'enable', 'on')
  set(findobj(h0, 'label', 'Rename Rater'), 'enable', 'on')
  set(findobj(h0, 'label', 'Copy Current Score'), 'enable', 'on')
  set(findobj(h0, 'label', 'Merge Scores'), 'enable', 'on')
  set(findobj(h0, 'label', 'Delete Current Score'), 'enable', 'on')
  set(findobj(h0, 'label', 'Score Statistics'), 'enable', 'on')
  %-------%
  
  %-------%
  %-create children in menu
  for i = 1:size(info.score,2)
    
    h_m = uimenu(m_rater, 'label', info.score{2,i}, 'call', @cb_rater);
    
    if i == info.rater
      set(h_m, 'check', 'on')
      set(findobj(h0, 'tag', 'p_hypno'), 'Title', ['Hypnogram: ' info.score{2,i}])
    end
    %-------%
  end
  %-----------------%
  
end
