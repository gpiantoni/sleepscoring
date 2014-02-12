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

%-------------------------------------%
%-update OPT if necessary
%-----------------%
%-assign optfile to info for new datasets
if nargin == 2
  info.optfile = opt.optfile;
elseif ~isfield(info, 'optfile')
    error('This should not happen: please email gio@gpiantoni.com about this, sorry')
end
%-----------------%

%-----------------%
%-try to read optfile in info, even if slightly different
if ~exist(info.optfile, 'file')
    [~, optname, ext] = fileparts(info.optfile);
    optfile = [fileparts(fileparts(mfilename('fullpath'))) ...
               filesep 'preference' ...
               filesep optname ext];
    if exist(optfile, 'file')
        info.optfile = optfile;
    else
        error(sprintf(['could not find optfile, \n' ...
              'please specify both info and opt file with the syntax:\n' ...
              'sleepscoring(''/path/to/score.mat'', ''/path/to/optfile.m'')']))
    end
end
%-----------------%

%-----------------%
%-if opt file is the default, don't consider it
[~, optname] = fileparts(opt.optfile);
if strcmp(optname, 'opt_default')
    opt.optfile = info.optfile;
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
  
  if ~strcmp(opt_chosen, opt_info)
    info.optfile = opt.optfile;
  end
  
end
%-----------------%
opt = prepare_opt(info.optfile, opt);

opt.epoch = 1;

%-----------------%
%-FIX SCORE if necessary
info = convert_score_cell2struct(info);
%-----------------%

%-----------------%
%-channels
[info, opt] = prepare_chan(info, opt);
%-----------------%
%-------------------------------------%

%---------------------------------------------------------%
%-FIGURE
%-------------------------------------%
%-information
setappdata(h0, 'info', info)
setappdata(h0, 'opt', opt)
%-------------------------------------%

%-------------------------------------%
%-INFO TEXT
set(opt.h.panel.info.infoname, 'str', info.infofile)
[~, filename] = fileparts(info.dataset);
set(opt.h.panel.data.h, 'title', filename)

[~, optname] = fileparts(opt.optfile);
set(opt.h.panel.info.optname, 'str', ['OPT: ' optname]);
%-------------------------------------%

%-------------------------------------%
%-enable PLOT
set(opt.h.axis.data, 'vis', 'on')
set(opt.h.axis.fft, 'vis', 'on')
set(opt.h.axis.hypno, 'vis', 'on')

set(h0, 'windowbuttonDownFcn', @cb_currentpoint)
%-------------------------------------%

%-------------------------------------%
%-SCORING HELP
score_popup(info, opt)
update_rater(info, opt)
%-------------------------------------%

%-------------------------------------%
%-enable MENU
set(opt.h.menu.score.h, 'enable', 'on')
set(opt.h.menu.chan.h, 'enable', 'on')
set(opt.h.menu.filt.h, 'enable', 'on')
set(opt.h.menu.ref.h, 'enable', 'on')

%-----------------%
%-CHAN SELECTION
delete(get(opt.h.menu.chan.h, 'children'))
for i = 1:numel(opt.changrp)
  uimenu(opt.h.menu.chan.h, 'label', opt.changrp(i).chantype, 'call', @cb_select_channel);
end
%-----------------%

%-----------------%
%-FILTER
delete(get(opt.h.menu.filt.h, 'children'))
for i = 1:numel(opt.changrp)
  uimenu(opt.h.menu.filt.h, 'label', opt.changrp(i).chantype, 'call', @cb_select_filter);
end
%-----------------%

%-----------------%
%-REFERENCE
delete(get(opt.h.menu.ref.h, 'children'))
for i = 1:numel(opt.changrp)
  uimenu(opt.h.menu.ref.h, 'label', opt.changrp(i).chantype, 'call', @cb_select_reference);
end
%-----------------%
%-------------------------------------%
%---------------------------------------------------------%