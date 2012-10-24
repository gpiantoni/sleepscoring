function cb_select_channel(h0, eventdata)
%CB_SELECT_CHANNEL select channels to plot for each group

chantype = get(h0, 'label');

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

%-------%
%-don't show labels belonging to another chantype
nolabel = arrayfun(@(x) x.chan, opt.changrp(~changrp), 'uni', 0);
nolabel = [nolabel{:}];
[~, ilabel] = setdiff(info.label, nolabel);
label = info.label(sort(ilabel));
%-------%

[~, chanindx] = intersect(label, opt.changrp(changrp).chan);
chanindx = select_channel_list(label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).chan = label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()
