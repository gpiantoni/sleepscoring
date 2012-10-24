function cb_select_reference(h0, eventdata)
%CB_SELECT_REFERENCE specify channels for reference

chantype = get(h0, 'label');

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(info.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(info.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = info.label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()