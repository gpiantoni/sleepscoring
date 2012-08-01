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

%-------------------------------------%
%-plot artifacts and other markers
for i = 1:3
  mrktype = i + 4; % row in FASST score
  
  art = info.score{mrktype, info.rater};
  
  if ~isempty(art)
    
    %-----------------%
    %-only artifact in epoch
    art_in_epoch = art(:,1) < epoch_end & art(:,2) > epoch_beg;
    art = art(art_in_epoch,:);
    %-----------------%
    
    for j = 1:size(art,1)
      
      %-----------------%
      %-range
      hold on
      h_f = fill(art(j,[1 1 2 2]), yrange([1 2 2 1]), opt.marker.color{i});
      set(h_f, 'tag', 'artifact')
      %-----------------%
      
    end
    
  end
  
end
%-------------------------------------%