function opt = opt_svui

opt = [];

%-------------------------------------%
%-CHANNAME (cannot be modified in GUI)
%-------------------------------------%
% Here you can rename channels, to give more meaningful names. 
% The first column is the labels read from the header file and the
% second column is the labels used in the analysis. The final labels will be
% stored in CFG. DO NOT GIVE TWO CHANNELS THE SAME NAME
%-----------------%
%-scalp EEG
opt.renamelabel = {'E41', 'F3';
                  'E214', 'F4';
                   'E59', 'C3';
                  'E183', 'C4';
                  'E124', 'O3';
                  'E149', 'O4';
                   'E94', 'LM'; % mastoid
                  'E190', 'RM';
                  'E234', 'REOG'; % EOG
                  'E244', 'LEOG';
                  'E165', 'EMG'};
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-PANEL POSITION (cannot be modified in GUI)
%-------------------------------------%
%-----------------%
%-horizontal dimensions
opt.marg.l = 0.025; % left margin
opt.width.l = 0.7; % width of objects on the left
opt.marg.r  = opt.marg.l + opt.width.l + 0.025; % margin between left and right
opt.width.r = 1 - opt.marg.r - opt.marg.l; % width of objects on the right
%-----------------%

%-----------------%
%-vertical dimensions
opt.marg.d = 0.025; % margin below
opt.height.d = 0.2; % height of objects below
opt.marg.u  = opt.marg.d + opt.height.d + 0.025; % margin between up and down
opt.height.u = 1 - opt.marg.u - opt.marg.d; % height of objects above
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-HYPNOGRAM (cannot be modified in GUI)
%-------------------------------------%
% Choose scoring standard
% hypnogram_RK for Rechtschaffen & Kales
% hypnogram_aasm2007 for AASM 2007 (does not have "movement time" nor "stage 3")
stage = hypnogram_RK;
opt.stage = stage;

opt.hypnogrid = 30; % will create a grid every X minutes in hypnogram
opt.arrowcolor = 'r'; % color of the arrow indicating the hypnogram
%-------------------------------------%

%-------------------------------------%
%-SHORTCUTS (cannot be modified in GUI)
%-------------------------------------%
opt.short.next = 'k';
opt.short.previous = 'j';
% '0' to '9' are reserved for sleep stages
%-------------------------------------%

%-------------------------------------%
%-MARKERS (cannot be modified in GUI)
%-------------------------------------%
opt.marker.selcolor = [.7 .7 .7]; % color used for selection, cannot be modified in the GUI
opt.marker.i = 1; % default index of opt.marker.name
opt.marker.name = {'movement' 'arousal' 'artifact'}; % TODO: modify names in GUI
opt.marker.color = {[1 .5 1] [.5 1 1] [1 1 .5] [.5 .5 1] [.5 1 .5] [1 .5 .5] [1 0 0] [0 1 0] [0 0 1]}; % colors, if not enough, they are reused (cannot be modified in GUI)
%-------------------------------------%

%-------------------------------------%
%-VISUALIZATION
%-------------------------------------%
%-----------------%
% (cannot be modified in GUI)
opt.scoreheight = 0.1; % height of the scoring color in the main window
opt.timegrid = 10; % time point every X s in plot
%-----------------%

%-----------------%
% (can be modified in GUI)
opt.ylim = [-1 1] * 150; % default size of the height

opt.grid0  = true;  % grid at zero
opt.grid75 = true;  % +- 75 uV grid
opt.grid1s = false; % one second grid
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-FFT
%-------------------------------------%
%-----------------%
% (cannot be modified in GUI)
opt.fft.welchdur = 2; % duration of welch's window in s (short -> more smoothing)
opt.fft.xlim = [0 40]; % if empty, it changes every time
opt.fft.ylim = [1e-2 1e3]; % if empty, it changes every time
%-----------------%

%-----------------%
% (can be modified in GUI)
opt.fft.i_chan = 1;
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CHANNEL GROUPS
%-------------------------------------%
%-the same channel cannot belong to two groups at the same time
opt.changrp(1).chantype = 'eeg'; % cannot be modified in GUI
opt.changrp(1).chan = {'F3' 'F4' 'C3' 'C4' 'O3'};  % can be modified in GUI
opt.changrp(1).ref = {'LM' 'RM'};  % can be modified in GUI
opt.changrp(1).Fhp = 0.3; % cannot be modified in GUI
opt.changrp(1).Flp = 35; % cannot be modified in GUI
opt.changrp(1).linecolor = 'k'; % cannot be modified in GUI
opt.changrp(1).scaling = 1; % cannot be modified in GUI

opt.changrp(2).chantype = 'eog';
opt.changrp(2).chan = {'REOG'};
opt.changrp(2).ref = {'LEOG'};
opt.changrp(2).Fhp = 0.3;
opt.changrp(2).Flp = 15;
opt.changrp(2).linecolor = 'r';
opt.changrp(2).scaling = 1;

opt.changrp(3).chantype = 'emg';
opt.changrp(3).chan = {'EMG'};
opt.changrp(3).ref = [];
opt.changrp(3).Fhp = 10;
opt.changrp(3).Flp = 100;
opt.changrp(3).linecolor = 'm';
opt.changrp(3).scaling = 1;

%- you can add any number of arbitrary channel types
% opt.changrp(4).chantype = 'ecg';
% opt.changrp(4).chan = []; % needs to be a cell
% opt.changrp(4).ref = [];
% opt.changrp(4).Fhp = 0.3;
% opt.changrp(4).Flp = 35;
% opt.changrp(4).linecolor = 'g';
%-------------------------------------%

