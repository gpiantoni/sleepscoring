function cb_select_channel(h, eventdata)
%CB_SELECT_CHANNEL select channels to plot for each group
%
% Called by
%  - sleepscoring

h0 = get_parent_fig(h);
chantype = get(h, 'label');

info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');

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

setappdata(h0, 'opt', opt);
cb_readplotdata(h0)
