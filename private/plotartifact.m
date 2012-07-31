function plotartifact

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

%-----------------%
%-time window
wndw = cfg.score{3,cfg.rater};
beginsleep = cfg.score{4,cfg.rater}(1);

epoch_beg = (opt.epoch - 1) * wndw + beginsleep; % add the beginning of the scoring period
epoch_end = epoch_beg + wndw - 1/cfg.fsample; % add length of time window and remove one sample
%-----------------%

%-----------------%
%-range on yaxis
yrange(1) = -1 * numel([opt.changrp.chan]) - 1;
yrange(2) = 0;
%-----------------%

%-----------------%
%-only artifact in epoch
art = cfg.score{5,cfg.rater};
art_in_epoch = art(:,1) <= epoch_end & art(:,2) >= epoch_beg;
art = art(art_in_epoch,:);
%-----------------%

if ~isempty(art)
  %-----------------%
  %-range
  hold on
  h_f = fill(art([1 1 2 2]), yrange([1 2 2 1]), 'm');
  set(h_f, 'tag', 'artifact')
  drawnow
  %-----------------%
end