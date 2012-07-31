function sleepscoring_init
%SLEEPSCORING_INIT initialize sleep scoring when a new dataset has been
% loaded
%TODO: this should be part of prepare_info, prepare_opt or prepare_score.
%If not, calle it "prepare_XXX"

%-----------------%
cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
%-----------------%

%-------------------------------------%
%-channels
for i = 1:size(opt.renamelabel,1)
  cfg.label{strcmp(cfg.label, opt.renamelabel{i,1})} = opt.renamelabel{i,2};
end
%-------------------------------------%

%-------------------------------------%
%-OPT
if ~isfield(opt, 'epoch')
  opt.epoch = 1;
end

if ~isempty(cfg.score)
  opt.beginsleep = cfg.score{4, cfg.rater}(1);
  opt.wndw = cfg.score{3, cfg.rater};
else
  opt.beginsleep = 1/cfg.hdr.Fs;
  opt.wndw = 30;
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
%-------------------------------------%

%-------------------------------------%
%-adjustment to GUI
[~, filename] = fileparts(cfg.dataset);
set(findobj('tag', 'p_data'), 'Title', filename)

set(opt.h.main, 'windowbuttonDownFcn', @cb_currentpoint)

%-----------------%
popup_score(cfg, opt)
popup_marker(cfg, opt)
%-----------------%

%-----------------%
setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)
%-----------------%
%-------------------------------------%