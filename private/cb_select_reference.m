function cb_select_reference(h, eventdata)
%CB_SELECT_REFERENCE specify channels for reference
%
% Called by
%  - sleepscoring

h0 = get_parent_fig(h);
chantype = get(h, 'label');

info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(info.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(info.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = info.label(chanindx)';

setappdata(h0, 'opt', opt);
cb_readplotdata(h0)