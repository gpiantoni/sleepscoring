function score_retime(pos, popup)

cfg = getappdata(0, 'cfg');

%-----------------%
%-check if sure to replace score
ConfirmDel = questdlg('Are you sure that you want to replace the current score?', ...
    'Redefining timing of the sleep scoring', ...
    'Yes', 'No', 'Yes');
if strcmp(ConfirmDel, 'No'); return; end
%-----------------%

%-----------------%
if strcmp(popup, 'sleep scoring begins (!)')
  
  cfg.score{4, cfg.rater}(1) = pos(1,1);
  
else

  cfg.score{4, cfg.rater}(2) = pos(1,1);
  
end
%-----------------%

%-----------------%
score = prepare_score(cfg.score(:,cfg.rater));
cfg.score(:,cfg.rater) = score;

setappdata(0, 'cfg', cfg);
cb_readplotdata()
%-----------------%
