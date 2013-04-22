function enable_marker(info, opt)
%ENABLE_MARKER enable or disable scrolling through markers
%
% Called by
%  - update_rater

epoch = get_epoch(info, opt);

if any(epoch > opt.epoch)
  set(opt.h.panel.info.marker.ff, 'enable', 'on')
else
  set(opt.h.panel.info.marker.ff, 'enable', 'off')
end

if any(epoch < opt.epoch)
  set(opt.h.panel.info.marker.bb, 'enable', 'on')
else
  set(opt.h.panel.info.marker.bb, 'enable', 'off')
end