function plot_event(info, opt, event)
%PLOT_EVENT function to plot events
%
% Called by
%  - cb_plotdata

event_color = [.5 0 0];

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
axes(opt.h.axis.data) % needs to be called inside, otherwise it does not work

samples = [event.sample] / info.fsample;
events_in_epoch = find(samples < epoch_end & samples > epoch_beg);

for i = 1:numel(events_in_epoch)
  evt = event(events_in_epoch(i));
  
  %-----------------%
  %-range
  hold on
  evt_start = evt.sample / info.fsample;
  evt_end = evt_start + (evt.duration / info.fsample);
  h_f = fill([evt_start evt_start evt_end evt_end], ...
             yrange([1 2 2 1]), event_color);
  set(h_f, 'tag', 'event')
  %-----------------%

  %-----------------%
  %-tag
  h_t = text(evt_start, yrange(1), evt.value, 'color', 'white', ...
    'backgroundcolor', 'black', 'verticalalignment', 'baseline');
  set(h_t, 'tag', 'event')
  %-----------------%
  
end
%-------------------------------------%
