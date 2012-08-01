function score_retime(pos, popup)
%SCORE_RETIME recreate the scoring epochs after you indicated the beginning
% and end of the sleep scoring

info = getappdata(0, 'info');

%-----------------%
%-check if sure to replace score
ConfirmDel = questdlg('Are you sure that you want to replace the current score?', ...
    'Redefining timing of the sleep scoring', ...
    'Yes', 'No', 'Yes');
if strcmp(ConfirmDel, 'No'); return; end
%-----------------%

%-----------------%
pos = round(pos(1,1) * info.fsample) / info.fsample;

if strcmp(popup, 'sleep scoring begins (!)')
  
  info.score{4, info.rater}(1) = pos;
  
else

  info.score{4, info.rater}(2) = pos;
  
end
%-----------------%

%-----------------%
score = prepare_score(info.score(:,info.rater));
info.score(:,info.rater) = score;

setappdata(0, 'info', info);
cb_readplotdata()
%-----------------%
