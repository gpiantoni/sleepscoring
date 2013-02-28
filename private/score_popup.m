function score_popup (info, opt)
%POPUP_SCORE create popup in information panel with current score
% and can be used to modify it too
% It's not run if the rater name is empty (you need to create a new scorer)
%
% Called by
%  - prepare_info_opt
%  - sleepscoring

%-------------------------------------%
%-only with real scores
if ~isempty(info.score(info.rater))
  
  %-----------------%
  %-find i_score, index of the current scoring
  stages = {opt.stage.label};
  score = info.score(info.rater).stage{opt.epoch};
  if isempty(score)
    score = stages(1); % default
  end
  i_score = find(strcmp(stages, score));
  %-----------------%
  
  %-----------------%
  %-score
  delete(findobj('tag', 'popupscore')) % delete in case it already exists
  uicontrol(findobj('tag', 'p_info'), 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .1 .9 .1], 'str', stages, 'val', i_score, 'tag', 'popupscore', ...
    'call', @cb_score);
  %-----------------%
  
  %-----------------%
  %-markers
  delete(findobj('tag', 'popupmarker')) % delete in case it already exists
  uicontrol(opt.h.info, 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .25 .9 .1], 'str', {info.score(info.rater).marker.name}, 'val', opt.marker.i, 'tag', 'popupmarker', ...
    'call', @cb_marker);
  %-----------------%
  
  drawnow
end
%-------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
%-------------------------------------%
function cb_score(h, eventdata)

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

i_score = get(h, 'val');
info.score(info.rater).stage{opt.epoch} = opt.stage(i_score).label;
save_info(info)
setappdata(h0, 'info', info)

opt.epoch = opt.epoch + 1;
setappdata(h0, 'opt', opt)

cb_readplotdata(h0)
%-------------------------------------%

%-------------------------------------%
function cb_marker(h, eventdata)

h0 = get_parent_fig(h);
opt = getappdata(h0, 'opt');
opt.marker.i = get(h0, 'val');
setappdata(h0, 'opt', opt)
%-------------------------------------%
%---------------------------------------------------------%