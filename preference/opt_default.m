function opt = opt_default

opt = [];

%-------------------------------------%
%-PANEL POSITION (cannot be modified in GUI)
%-------------------------------------%
%-----------------%
%-horizontal dimensions
opt.marg_l = 0.025; % left margin
opt.width_l = 0.7; % width of objects on the left
opt.marg_r  = opt.marg_l + opt.width_l + 0.025; % margin between left and right
opt.width_r = 1 - opt.marg_r - opt.marg_l; % width of objects on the right
%-----------------%

%-----------------%
%-vertical dimensions
opt.marg_d = 0.025; % margin below
opt.height_d = 0.2; % height of objects below
opt.marg_u  = opt.marg_d + opt.height_d + 0.025; % margin between up and down
opt.height_u = 1 - opt.marg_u - opt.marg_d; % height of objects above
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-HYPNOGRAM (cannot be modified in GUI)
%-------------------------------------%
%-code is the number saved in score{1,1}
%-label is the corresponding state
%-color is the color used for plotting
%-height is the height of the bar
stage = [];
stage(1).code = 0;
stage(1).label = 'Awake';
stage(1).color = [0.2 0.75 0.6];
stage(1).height = 7;

stage(2).label = 'MT';
stage(2).code = 6;
stage(2).color = [0.9 0.4 0.4];
stage(2).height = 6;

stage(3).label = 'REM';
stage(3).code = 5;
stage(3).color = [0.1 0.5 0.9];
stage(3).height = 5;

stage(4).label = 'Stage 1';
stage(4).code = 1;
stage(4).color = [0.1 0.1 0.9];
stage(4).height = 4;

stage(5).label = 'Stage 2';
stage(5).code = 2;
stage(5).color = [0.1 0.1 0.75];
stage(5).height = 3;

stage(6).label = 'Stage 3';
stage(6).code = 3;
stage(6).color = [0.1 0.1 0.6];
stage(6).height = 2;

stage(7).label = 'Stage 4';
stage(7).code = 4;
stage(7).color = [0.1 0.1 0.45];
stage(7).height = 1;

opt.stage = stage;
opt.hypnogrid = 30; % will create a grid every XX minutes
opt.arrowcolor = 'r'; % color of the arrow indicating the hypnogram
%-------------------------------------%

%-------------------------------------%
%-VISUALIZATION
%-------------------------------------%
opt.scoreheight = 0.1; % height of the scoring color in the main window

opt.ylim = [-1 1] * 150; % default size of the height

opt.grid75 = true;  % +- 75 uV grid
opt.grid1s = false; % one second grid
%-------------------------------------%

%-------------------------------------%
%-CHANNEL GROUPS (can be modified in GUI)
%-------------------------------------%
%-the same channel cannot belong to two groups at the same time
opt.changrp(1).chantype = 'eeg';
opt.changrp(1).chan = {'E41' 'E214' 'E59' 'E124' 'E149' 'E183'};
opt.changrp(1).ref = {'E94' 'E190'};
opt.changrp(1).Fhp = 0.3;
opt.changrp(1).Flp = 35;
opt.changrp(1).linecolor = 'k';
opt.changrp(1).scaling = 1;

opt.changrp(2).chantype = 'eog';
opt.changrp(2).chan = {'E234'};
opt.changrp(2).ref = {'LEOG'};
opt.changrp(2).Fhp = 0.1;
opt.changrp(2).Flp = 12;
opt.changrp(2).linecolor = 'r';
opt.changrp(2).scaling = 1;

opt.changrp(3).chantype = 'emg';
opt.changrp(3).chan = {'E165'};
opt.changrp(3).ref = [];
opt.changrp(3).Fhp = 0.3;
opt.changrp(3).Flp = 35;
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
