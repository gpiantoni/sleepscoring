function [info opt] = prepare_chan(info, opt)
%PREPARE_CHAN prepare channels, by renaming what's necessary
%
% Called by:
%  - prepare_info_opt

%-----------------%
%-INFO: rename channels
if isempty(setdiff(info.label, info.hdr.label)) % it they haven't been renamed yet
  for i = 1:size(opt.renamelabel,1)
    
    i_lbl = strcmp(info.label, opt.renamelabel{i,1});
    if any(i_lbl)
      info.label{i_lbl} = opt.renamelabel{i,2};
    else
      warning(['could not find channel ' opt.renamelabel{i,1} ', so not renamed to ' opt.renamelabel{i,2}])
    end
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