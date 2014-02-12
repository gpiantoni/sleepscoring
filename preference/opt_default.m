function opt = opt_default
% minimal opt for creating an empty sleepscoring

opt = [];

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
%-VISUALIZATION
%-------------------------------------%
%-----------------%
% (can be modified in GUI)
opt.ylim = [-1 1] * 150; % default size of the height

opt.grid0  = true;  % grid at zero
opt.grid75 = true;  % +- 75 uV grid
opt.grid1s = false; % one second grid
%-----------------%
%-------------------------------------%
