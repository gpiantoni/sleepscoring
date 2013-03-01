function prepare_info_opt(h0, dummy)
%PREPARE_INFO_OPT combine information from info, opt and score
%
% dummy is necessary: if you open optfile in sleepscoring>cb_openopt, it
% does not make sense to ask if you want to open it
% 
% Called by
%  - cb_newinfo>cb_ok
%  - sleepscoring
%  - sleepscoring>cb_openinfo
%  - sleepscoring>cb_openopt

%-----------------%
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');
%-----------------%

%-----------------%
%-assign optfile to info if it doesn't exist (for new datasets)
if ~isfield(info, 'optfile')
  info.optfile = opt.optfile;
end
%-----------------%

%-----------------%
%-if the opt files are different in the info and opt, let the user choose
if nargin == 1 && ~strcmp(info.optfile, opt.optfile)
  opt_info = ['in the dataset: ' info.optfile];
  opt_opt = ['in the option: ' opt.optfile];
  
  opt_chosen = questdlg(sprintf('The option file in the dataset and the one in memory do not match.\nWhich one do you want to use?'), ...
    'Option File to Use', ...
    opt_info, opt_opt, opt_info);
  
  if strcmp(opt_chosen, opt_info) % in info, load the one present in info
    opt = prepare_opt(info.optfile, opt);
  else
    info.optfile = opt.optfile;
  end
  
end
%-----------------%

opt.epoch = 1;

%-------------------------------------%
%-channels
[info opt] = prepare_chan(info, chan);
%-------------------------------------%

%-------------------------------------%
%-GUI
%-----------------%
setappdata(h0, 'info', info)
setappdata(h0, 'opt', opt)

%-----------------%
%-INFO TEXT
set(findobj(h0, 'tag', 'name_info'), 'str', info.infofile)
[~, filename] = fileparts(info.dataset);
set(findobj(h0, 'tag', 'p_data'), 'title', filename)

[~, optname] = fileparts(opt.optfile);
set(findobj(h0, 'tag', 'name_opt'), 'str', ['OPT: ' optname]);
%-----------------%

%-----------------%
score_popup(info, opt)
update_rater(h0, info)
%-----------------%

%-----------------%
%-working GUI
set(findobj(h0, 'label', 'Sleep Score'), 'enable', 'on')
delete(findobj(h0, 'label', 'Channel Selection'))
delete(findobj(h0, 'label', 'Filter'))
delete(findobj(h0, 'label', 'Reference'))

%-----------------%
%-CHAN SELECTION
m_chan = uimenu(h0, 'label', 'Channel Selection');
for i = 1:numel(opt.changrp)
  uimenu(m_chan, 'label', opt.changrp(i).chantype, 'call', @cb_select_channel);
end
%-----------------%

%-----------------%
%-FILTER
m_filt = uimenu(h0, 'label', 'Filter');
for i = 1:numel(opt.changrp)
  uimenu(m_filt, 'label', opt.changrp(i).chantype, 'call', @cb_select_filter);
end
%-----------------%

%-----------------%
%-REFERENCE
m_ref = uimenu(h0, 'label', 'Reference');
for i = 1:numel(opt.changrp)
  uimenu(m_ref, 'label', opt.changrp(i).chantype, 'call', @cb_select_reference);
end
%-----------------%

set(h0, 'windowbuttonDownFcn', @cb_currentpoint)
%-----------------%
%-------------------------------------%