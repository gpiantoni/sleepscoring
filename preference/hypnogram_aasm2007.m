function stage = hypnogram_aasm2007
%HYPNOGRAM_AASM2007 Define stages according to AASM, 2007
%
%-code is the number saved in score{1,1}
%-label is the corresponding state
%-color is the color used for plotting
%-height is the height of the bar
%
% Iber, C., Ancoli-Israel, S., Chesson, A.L., and Quan, S.F. (2007). The
% AASM manual for the scoring of sleep and associated events: rules,
% terminology, and technical specifications (Westchester, IL: American
% Academy of Sleep Medicine).

stage(1).code = 0;
stage(1).label = 'Wakefulness';
stage(1).color = [0.2 0.75 0.6];
stage(1).height = 7;

stage(2).label = 'REM';
stage(2).code = 5;
stage(2).color = [0.1 0.5 0.9];
stage(2).height = 4;

stage(3).label = 'NREM 1';
stage(3).code = 1;
stage(3).color = [0.1 0.1 0.9];
stage(3).height = 3;

stage(4).label = 'NREM 2';
stage(4).code = 2;
stage(4).color = [0.1 0.1 0.75];
stage(4).height = 2;

stage(5).label = 'NREM 3';
stage(5).code = 3;
stage(5).color = [0.1 0.1 0.45];
stage(5).height = 1;

stage(6).label = 'NOT SCORED';
stage(6).code = NaN; % remember that == does not work with NaN
stage(6).color = [1 1 1];
stage(6).height = 0;
