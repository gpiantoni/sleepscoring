function sleepdetection(cfg, info)
%SLEEPDETECTION detect sleep parameters on info dataset
%
% CFG

% INFO
%  .dataset: the dataset to read, with the raw data
%  .infofile: the MAT file to save information to

% if nargin == 1
%   cb_newinfo (but you need to fix this function so that it does not plot
%   immediately
% end

info = prepare_info(info);
opt = prepare_opt(info.optfile);

keyboard

