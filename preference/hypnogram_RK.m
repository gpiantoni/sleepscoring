function stage = hypnogram_RK
%HYPNOGRAM_RK Define stages according to Rechtschaffen & Kales, 1968
%
%-label is the corresponding state
%-color is the color used for plotting
%-height is the height of the bar
%
% Rechtschaffen, A. & Kales, A., eds (1968). A manual of standardized
% terminology, techniques and scoring system for sleep stages of human
% subjects (Los Angeles, CA: BIS/BRI, UCLA).  

%-the first group is used as default
stage(1).label = 'NOT SCORED';
stage(1).color = [1 1 1];
stage(1).height = 0;

stage(2).label = 'Awake';
stage(2).color = [0.2 0.75 0.6];
stage(2).height = 7;

stage(3).label = 'MT';
stage(3).color = [0.9 0.4 0.4];
stage(3).height = 6;

stage(4).label = 'REM';
stage(4).color = [0.1 0.5 0.9];
stage(4).height = 5;

stage(5).label = 'Stage 1';
stage(5).color = [0.1 0.1 0.9];
stage(5).height = 4;

stage(6).label = 'Stage 2';
stage(6).color = [0.1 0.1 0.75];
stage(6).height = 3;

stage(7).label = 'Stage 3';
stage(7).color = [0.1 0.1 0.6];
stage(7).height = 2;

stage(8).label = 'Stage 4';
stage(8).color = [0.1 0.1 0.45];
stage(8).height = 1;

