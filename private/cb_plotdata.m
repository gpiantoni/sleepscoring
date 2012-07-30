%-------------------------------------%
%-callback: plot data only
function cb_plotdata(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
dat = getappdata(0, 'dat');

delete(findobj('tag', 'a_dat'))
axes('parent', opt.h.data, 'tag', 'a_dat');
plotdata(cfg, opt, dat);

delete(findobj('tag', 'a_fft'))
axes('parent', opt.h.fft, 'tag', 'a_fft');
plotfft()

if ~isempty(cfg.score)
  
  delete(findobj('tag', 'a_hypno'))
  axes('parent', findobj('tag', 'p_hypno'), 'tag', 'a_hypno');
  hypnogram(opt, cfg.score(:, cfg.rater))
  popup_score(cfg, opt)
  
end
%-------------------------------------%