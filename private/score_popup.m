function score_popup (info, opt)
%POPUP_SCORE create popup in information panel with current score
% and can be used to modify it too
% It's not run if the rater name is empty (you need to create a new scorer)
%
% Called by
%  - prepare_info_opt

%-------------------------------------%
%-only with real scores
if ~isempty(info.score(info.rater))
  
  %-----------------%
  %-find i_score, index of the current scoring
  stages = {opt.stage.label};
  score = info.score(1, info.rater).stage{opt.epoch};
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
    'pos', [.05 .25 .9 .1], 'str', opt.marker.name, 'val', opt.marker.i, 'tag', 'popupmarker', ...
    'call', @cb_marker);
  %-----------------%
  
  drawnow
end
%-------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
%-------------------------------------%
function cb_score(h0, eventdata)

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

i_score = get(h0, 'val');
info.score{1, info.rater}(opt.epoch) = opt.stage(i_score).code;
save_info()

opt.epoch = opt.epoch + 1;
setappdata(0, 'info', info)
setappdata(0, 'opt', opt)
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
function cb_marker(h0, eventdata)

opt = getappdata(0, 'opt');
opt.marker.i = get(h0, 'val');
setappdata(0, 'opt', opt)
%-------------------------------------%
%---------------------------------------------------------%