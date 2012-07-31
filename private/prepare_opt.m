function opt = prepare_opt(optname, opt_old)
%PREPARE_OPT read or prepare opt
% Input can be a file ending in ".m" (such as "opt_default.m") or a MAT
% file with a "opt" variable.
%
% OPT
%  .optname: name of the opt file
%
%-channels
%  .renamelabel: two-column cell, the first column is the labels read from
%                the header file and the second column is the labels used
%                in the analysis. The final labels will be stored in CFG 
%  .changrp:
%    .chantype
%    .chan: cells with channels
%    .ref: reference for this channel group
%    .Fhp: high-pass filter cutoff
%    .Flp: low-pass filter cutoff
%    .linecolor: color for the channel group
%    .scaling: scaling of the channel group
%
%-main window
%  .marg, .width, .height: dimension of main panels
%
%  .epoch: index of the epoch
%
%-data panel
%  .scoreheight: location of the score colorbar on top of scoring (used by plotdata)
%  .timegrid: put a label in data panel every X seconds
%  .grid0: show grid at 0 uV
%  .grid75: show grid at +- 75 uV
%  .grid1s: show grid at 1s
%  .ylim: vertical limit in uV
%  .marker: cell with strings of possible marker (right-click to select them)
%
%-hypno panel
%  .hypnogrid: make a grid in hypnogram every X minutes
%  .arrowcolor: color of the arrow indicating the current epoch
%  .stage:
%    .code: code of the stage in FASST scoring
%    .label: label of the stage next to hypnogram
%    .color: color in the hypnogram
%    .height: height in hypnogram
%
%-fft panel
% .fft:
%   .i_chan: index of the channel for FFT
%   .welchdur: duration of the welch's window in s
%   .xlim: limit of the x axis (if empty, it's adaptive)
%   .ylim: limit of the y axis (if empty, it's adaptive), log-scale
%
%-shortcuts
% .short:
%   .next: following epoch
%   .previous: previous epoch
%
%-figure handles
%  .h:
%    .main: main figure handle
%    .data: data panel
%    .hypno: hypno panel
%    .info: info panel
%    .fft: fft panel
%  .axis:
%    .data: axis of the data panel
%    .hypno: axis of hypno panel
%    .fft: axis of fft panel

% TODO: check opt

%-----------------%
%-read opt
if strcmp(optname(end-1:end), '.m') % if it's the .m file like opt_default
  opt = feval(optname(1:end-2)); % remove .m
  
elseif strcmp(optname(end-3:end), '.mat') % saved from previous OPT
  load(optname, 'opt')
  
end

opt.optname = optname;
%-----------------%

%-----------------%
%-handles (specific to a figure)
if nargin == 2
  opt.h = opt_old.h;
  opt.axis = opt_old.axis;
end
%-----------------%

%-----------------%
%rename CFG
set(findobj( 'tag', 'name_opt'), 'str', ['OPT: ' opt.optname]);
%-----------------%
