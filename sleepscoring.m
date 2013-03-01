function sleepscoring(info, opt)
%SLEEPSCORING do sleep scoring on EGI data without modifying the data
% The function reads the data directly from disk and keeps the scoring
% information separate from the data. There are two types of parameters for
% sleep scoring:
% 1- Parameters which is specific to the dataset ('info') 
% 2- Parameters about the visualization, not specific to the dataset ('opt')
%
% The two structures are saved and dealt with differently. 
% 1- INFO contains all the sleep scoring and other information specific to
%    the dataset, as it's stored in a .MAT file as structure. It's saved
%    every time you modify it (f.e. by changing sleep scoring).
% 2- OPT contains all the information about visualization, it can be stored
%    in a .m file (such as "opt_svui.m") or in a .MAT file as structure.
%    See PREPARE_OPT for more information
%    This structure is NOT saved automatically. 
%
% Use as:
%   SLEEPSCORING uses default "opt_svui.m" in folder "preferences"
% 
%   SLEEPSCORING(INFO) where INFO contains at least a field called 
%                     .dataset which points to the dataset to read
%                     If you specify a .infofile, it'll save the INFO
%                     variable in the file .infofile.
%
%   SLEEPSCORING(INFO, OPT) where OPT is a file similar to "opt_svui.m",
%                           but modified by you for your parameters 
%   SLEEPSCORING(INFO, OPT) where OPT is a .MAT file with a "opt" variable
%                           saved from a previous analysis 
%   SLEEPSCORING(INFO, OPT) where OPT is the "opt" variable from a previous
%                           analysis 

%TODO:
% - automatic detection of SW and spindles
% - automatic scoring

%---------------------------------------------------------%
%-GUI FUNCTION
%---------------------------------------------------------%

%-------------------------------------%
%-CHECK INPUT
ftdir = which('ft_read_header');
if strcmp(ftdir, '')
  error('Please add fieldtrip folder and execute ''ft_defaults''')
end

if nargin < 2 || isempty(opt)
  opt = [fileparts(mfilename('fullpath')) filesep 'preference' filesep 'opt_ssmd_egi.m']; % default OPT
end
%-------------------------------------%

%-------------------------------------%
%-OPT: preferences
opt = prepare_opt(opt);
%-------------------------------------%

%-------------------------------------%
%-create figure with handles
opt.h = create_handles(opt);
%-------------------------------------%

%-------------------------------------%
%-read the data if present in info
setappdata(opt.h.main, 'opt', opt)

if nargin > 0 && ischar(info)
  infofile = info;
  info = [];
  info.infofile = infofile;
end

if nargin > 0 && (isfield(info, 'dataset') || isfield(info, 'infofile'))
  
  [info hdr] = prepare_info(info);
  
  save_info(info)
  setappdata(opt.h.main, 'info', info)
  setappdata(opt.h.main, 'hdr', hdr)
    
  prepare_info_opt(opt.h.main)
  cb_readplotdata(opt.h.main)
  
end
%-------------------------------------%
%---------------------------------------------------------%