function plot_marker(info, opt)
%PLOT_MARKER function to plot markers
%
% Called by
%  - cb_plotdata

%-----------------%
%-time window
wndw = info.score(info.rater).wndw;
beginsleep = info.score(info.rater).score_beg;

epoch_beg = (opt.epoch - 1) * wndw + beginsleep; % add the beginning of the scoring period
epoch_end = epoch_beg + wndw - 1/info.fsample; % add length of time window and remove one sample
%-----------------%

%-----------------%
%-range on yaxis
yrange(1) = -1 * numel([opt.changrp.chan]) - 1;
yrange(2) = 0;
%-----------------%

%-------------------------------------%
%-plot markers
for mrktype = 1:numel(info.score(info.rater).marker)
  
  mrk = info.score(info.rater).marker(mrktype).time;
  
  if ~isempty(mrk)
    
    %-----------------%
    %-only artifact in epoch
    mrk_in_epoch = mrk(:,1) < epoch_end & mrk(:,2) > epoch_beg;
    mrk = mrk(mrk_in_epoch,:);
    %-----------------%
    
    for j = 1:size(mrk,1)
      
      %-----------------%
      %-range
      hold on
      i_col = mod(numel(opt.marker.color), mrktype);
      h_f = fill(mrk(j,[1 1 2 2]), yrange([1 2 2 1]), opt.marker.color{i_col});
      set(h_f, 'tag', 'marker')
      %-----------------%
      
    end
    
  end
  
end
%-------------------------------------%