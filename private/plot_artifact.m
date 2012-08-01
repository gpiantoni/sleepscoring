function plot_artifact
%PLOT_ARTIFACT function to plot artifact and other markers

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

%-----------------%
%-time window
wndw = info.score{3,info.rater};
beginsleep = info.score{4,info.rater}(1);

epoch_beg = (opt.epoch - 1) * wndw + beginsleep; % add the beginning of the scoring period
epoch_end = epoch_beg + wndw - 1/info.fsample; % add length of time window and remove one sample
%-----------------%

%-----------------%
%-range on yaxis
yrange(1) = -1 * numel([opt.changrp.chan]) - 1;
yrange(2) = 0;
%-----------------%

art = info.score{5,info.rater};

if ~isempty(art)
  
  %-----------------%
  %-only artifact in epoch
  art_in_epoch = art(:,1) <= epoch_end & art(:,2) >= epoch_beg;
  art = art(art_in_epoch,:);
  %-----------------%
  
  %-----------------%
  %-range
  hold on
  h_f = fill(art([1 1 2 2]), yrange([1 2 2 1]), opt.marker.color{1});
  set(h_f, 'tag', 'artifact')
  drawnow
  %-----------------%
  
end