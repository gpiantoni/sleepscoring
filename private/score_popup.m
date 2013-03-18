function score_popup(info, opt)
%POPUP_SCORE create popup in information panel with current score
% and can be used to modify it too
% It's not run if the rater name is empty (you need to create a new scorer)
%
% Called by
%  - prepare_info_opt
%  - cb_readplotdata

%-------------------------------------%
%-only with real scores
if ~isempty(info.score(info.rater).rater)
  
  %-----------------%
  %-find i_score, index of the current scoring
  stages = {opt.stage.label};
  score = info.score(info.rater).stage{opt.epoch};
  if isempty(score)
    score = stages(1); % default stage
  end
  i_score = find(strcmp(stages, score));
  %-----------------%
  
  %-----------------%
  %-score
  set(opt.h.panel.info.popupscore, 'str', stages, ...
    'val', i_score, 'vis', 'on');
  %-----------------%
  
  %-----------------%
  %-markers
  set(opt.h.panel.info.marker.popup, 'str', {info.score(info.rater).marker.name}, ...
    'val', opt.marker.i, 'vis', 'on');
  set(opt.h.panel.info.marker.bb, 'vis', 'on');
  set(opt.h.panel.info.marker.edit, 'vis', 'on');
  set(opt.h.panel.info.marker.ff, 'vis', 'on');
  %-----------------%
  
else
  
  %-return to default (for example, if rater was deleted)
  set(opt.h.panel.info.popupscore, 'str', {''}, 'val', 1, 'vis', 'off');
  set(opt.h.panel.info.marker.popup, 'str', {''}, 'val', 1, 'vis', 'off');
  set(opt.h.panel.info.marker.bb, 'vis', 'off');
  set(opt.h.panel.info.marker.edit, 'vis', 'off');
  set(opt.h.panel.info.marker.ff, 'vis', 'off');
  
end
drawnow
%-------------------------------------%
