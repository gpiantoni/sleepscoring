function sleepscoring_init
%SLEEPSCORING_INIT initialize sleep scoring when a new dataset has been
% loaded

%-----------------%
cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
%-----------------%

%-----------------%
%-CFG
cfg.label = feval(cfg.default.chan, cfg.hdr.label);

if isfield(cfg, 'score')
  if ~isfield(cfg, 'rater')
    cfg.rater = 1;
  end
else
  cfg.score = [];
end

if ~isempty(cfg.score)
  cfg.wndw = cfg.score{3, cfg.rater};
else
  cfg.wndw = 30;
end
%-----------------%

%-----------------%
%-OPT
if ~isfield(opt, 'epoch')
  opt.epoch = 1;
end

if ~isempty(cfg.score)
  opt.recbegin = cfg.score{4, cfg.rater}(1);
else
  opt.recbegin = 1/cfg.hdr.Fs;
end

for i = 1:numel(opt.changrp)
  [~, chanidx] = intersect(cfg.label, opt.changrp(i).chan);
  
  %-------%
  if numel(chanidx) ~= numel(opt.changrp(i).chan)
    nochan = setdiff(opt.changrp(i).chan, cfg.label);
    nochan = sprintf(' %s,', nochan{:});
    error(sprintf(['You want channels which are not in the data: ' nochan '\nBe careful with channame.m and the channel groups in opt_default.m']))
  end
  %-------%
  
  opt.changrp(i).chan = cfg.label(sort(chanidx))';
end
%-----------------%

%-----------------%
%-adjustment to GUI
[~, filename] = fileparts(cfg.dataset);
set(findobj('tag', 'p_data'), 'Title', filename)

set(opt.h.main, 'windowbuttonDownFcn', @cb_currentpoint)

popup_score(cfg, opt)
popup_marker(cfg, opt)
%-----------------%

%-----------------%
setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)
%-----------------%