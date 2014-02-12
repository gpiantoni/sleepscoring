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
%    in a .m file (such as "opt_default.m") or in a .MAT file as structure.
%    See PREPARE_OPT for more information
%    This structure is NOT saved automatically. 
%
% Use as:
%   SLEEPSCORING uses default "opt_default.m" in folder "preferences"
% 
%   SLEEPSCORING(INFO) where INFO contains at least:
%                     .dataset : path to the dataset to read
%                     .infofile : where to save the information
%                     .optfile : path to optfile
%
%   SLEEPSCORING(INFO, OPT) where OPT is a file similar to "opt_default.m",
%                           but modified by you for your parameters 
%   SLEEPSCORING(INFO, OPT) where OPT is a .MAT file with a "opt" variable
%                           saved from a previous analysis 
%   SLEEPSCORING(INFO, OPT) where OPT is the "opt" variable from a previous
%                           analysis 

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
  opt = [fileparts(mfilename('fullpath')) filesep 'preference' filesep 'opt_default.m']; % default OPT
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
  [infodir, infofile, infoext] = fileparts(info);
  if strcmp(infodir, '')
    infodir = pwd;
  end
  info = [];
  info.infofile = [infodir, filesep, infofile, infoext];
end

if nargin > 0 && (isfield(info, 'dataset') || isfield(info, 'infofile'))
  
  [info hdr] = prepare_info(info);
  
  save_info(info)
  setappdata(opt.h.main, 'info', info)
  setappdata(opt.h.main, 'hdr', hdr)
  
  if nargin == 1
    prepare_info_opt(opt.h.main)
  elseif nargin == 2
    prepare_info_opt(opt.h.main, 1)
  end
  cb_readplotdata(opt.h.main)
  
end
%-------------------------------------%
%---------------------------------------------------------%