function stage = hypnogram_aasm2007
%HYPNOGRAM_AASM2007 Define stages according to AASM, 2007
%
%-label is the name of the sleep state
%-shortcut is the keyboard shortcut 
%-color is the color used for plotting
%-height is the height of the bar
%
% Iber, C., Ancoli-Israel, S., Chesson, A.L., and Quan, S.F. (2007). The
% AASM manual for the scoring of sleep and associated events: rules,
% terminology, and technical specifications (Westchester, IL: American
% Academy of Sleep Medicine).

%-the first group is used as default
stage(1).label = 'NOT SCORED';
stage(1).shortcut = '9';
stage(1).color = [1 1 1];
stage(1).height = 0;

stage(2).label = 'Wakefulness';
stage(2).shortcut = '0';
stage(2).color = [0.2 0.75 0.6];
stage(2).height = 7;

stage(3).label = 'REM';
stage(3).shortcut = '5';
stage(3).color = [0.1 0.5 0.9];
stage(3).height = 4;

stage(4).label = 'NREM 1';
stage(4).shortcut = '1';
stage(4).color = [0.1 0.1 0.9];
stage(4).height = 3;

stage(5).label = 'NREM 2';
stage(5).shortcut = '2';
stage(5).color = [0.1 0.1 0.75];
stage(5).height = 2;

stage(6).label = 'NREM 3';
stage(6).shortcut = '3';
stage(6).color = [0.1 0.1 0.45];
stage(6).height = 1;

