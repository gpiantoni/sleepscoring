function popup_score(cfg, opt)
%---------------------------------------------------------%
%-MAIN FUNCTION
%---------------------------------------------------------%
if ~isempty(cfg.score)
  
  stages = {opt.stage.label};
  score = cfg.score{1, cfg.rater}(opt.epoch);
  i_score = find([opt.stage.code] == score);
  if isempty(i_score)
    i_score = find(isnan([opt.stage.code]));
  end

  uicontrol(findobj('tag', 'p_info'), 'sty', 'popup', 'uni', 'norm', ...
    'pos', [.05 .1 .9 .1], 'str', stages, 'val', i_score, 'tag', 'popupscore', ...
    'call', @cb_score);
  drawnow
  
end
%---------------------------------------------------------%


%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%
function cb_score(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

i_score = get(h, 'val');
cfg.score{1, cfg.rater}(opt.epoch) = opt.stage(i_score).code;
savecfg()

opt.epoch = opt.epoch + 1;

setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)
cb_readplotdata()
%---------------------------------------------------------%