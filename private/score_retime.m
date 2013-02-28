function score_retime(pos, popup)
%SCORE_RETIME recreate the scoring epochs after you indicated the beginning
% and end of the sleep scoring
%
% Called by
%  - cb_currentpoint

info = getappdata(0, 'info');

%-----------------%
%-check if sure to replace score
ConfirmDel = questdlg('Are you sure that you want to replace the current score?', ...
    'Redefining timing of the sleep scoring', ...
    'Yes', 'No', 'Yes');
if strcmp(ConfirmDel, 'No'); return; end
%-----------------%

%-----------------%
info = prepare_log('score_backup', info);
pos = round(pos(1,1) * info.fsample) / info.fsample;

if strcmp(popup, 'sleep scoring begins (!)')
  info.score(info.rater).score_beg = pos * info.fsample;
  info = prepare_log('score_begin', info);
  
else
  info.score(info.rater).score_end = pos * info.fsample;
  info = prepare_log('score_end', info);
  
end
%-----------------%

%-----------------%
%-modify score timing
dur = info.score(info.rater).score_end - info.score(info.rater).score_beg;
nscore = floor(dur / info.score(info.rater).wndw);
info.score(info.rater).stage = cell(1, nscore);

setappdata(0, 'info', info);
%-----------------%

%-----------------%
%-go to first epoch
opt = getappdata(0, 'opt');
opt.epoch = 1;
setappdata(0, 'opt', opt)
%-----------------%

cb_readplotdata()
