%-------------------------------------%
%-callback: plot data only
function cb_plotdata(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
dat = getappdata(0, 'dat');

delete(findobj('tag', 'dat'))
axes('parent', findobj('tag', 'p_data'), 'tag', 'dat');
plotdata(cfg, opt, dat); % feval

if ~isempty(cfg.score)
  axes('parent', findobj('tag', 'p_hypno'), 'tag', 'dat');
  hypnogram(opt, cfg.score(:,cfg.rater))
end
%-------------------------------------%