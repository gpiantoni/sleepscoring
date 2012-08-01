function prepare_info_opt
%PREPARE_INFO_OPT combine information from info, opt and score

%-----------------%
info = getappdata(0, 'info');
opt = getappdata(0, 'opt');
opt.epoch = 1;
%-----------------%

%-------------------------------------%
%-CHANNELS
%-----------------%
%-INFO: rename channels
if isempty(setdiff(info.label, info.hdr.label)) % it they haven't been renamed yet
  for i = 1:size(opt.renamelabel,1)
    info.label{strcmp(info.label, opt.renamelabel{i,1})} = opt.renamelabel{i,2};
  end
end
%-----------------%

%-----------------%
%-OPT: check that channels are present and sort them
for i = 1:numel(opt.changrp)
  [~, chanidx] = intersect(info.label, opt.changrp(i).chan);
  
  %-------%
  if numel(chanidx) ~= numel(opt.changrp(i).chan)
    nochan = setdiff(opt.changrp(i).chan, info.label);
    nochan = sprintf(' %s,', nochan{:});
    error(sprintf(['You want channels which are not in the data: ' nochan '\nBe careful with channame.m and the channel groups in opt_default.m']))
  end
  %-------%
  
  opt.changrp(i).chan = info.label(sort(chanidx))';
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-GUI
%-----------------%
setappdata(0, 'info', info)
setappdata(0, 'opt', opt)
%-----------------%

%-----------------%
popup_score(info, opt)
update_rater(info)
%-----------------%

%-----------------%
%-working GUI
set(findobj('label', 'Sleep Score'), 'enable', 'on')
set(findobj('label', 'Channel Selection'), 'enable', 'on')
set(findobj('label', 'Filter'), 'enable', 'on')
set(findobj('label', 'Reference'), 'enable', 'on')
set(opt.h.main, 'windowbuttonDownFcn', @cb_currentpoint)
%-----------------%
%-------------------------------------%