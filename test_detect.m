% TO UPDATE SLEEPSCORING
% cd ~/matlab/toolbox/sleepscoring
% git pull origin master

addpath /usr/local/MATLAB/R2012a/toolbox/fieldtrip-20160713/
addpath matlab/toolbox/sleepscoring/
ft_defaults

% 1. create data
info = [];

%- input
info.dataset = '/mnt/anw-archive/NP/yvdwerf/EEGdata/rawdata/h_con_05-edf.edf';
info.optfile = '/home/yvdwerf/matlab/toolbox/sleepscoring/preference/opt_edf_memconsol.m';

%-output
info.infofile = '/home/yvdwerf/matlab/cortisol/nights/subj_05.mat';

sleepscoring(info)

% 2. import score from somnologica
% (it's saved automatically)

% 3. get info (optional)
info = getappdata(gcf, 'info');

% 4. reload data
%-from variable
sleepscoring(info)

%-from disk
sleepscoring('/home/yvdwerf/matlab/cortisol/nights/subj_03.mat')

% 5. slow wave detection

% stages: 'Wakefulness', 'NREM 1', 'NREM 2', 'NREM 3', 'REM',

cfg = [];
cfg.method.name = 'slowwave';
cfg.method.fun = 'detect_slowwave';
cfg.method.chan = 1:6;
cfg.method.epoch = {'NREM 2', 'NREM 3'};
cfg.method.ref = {'A1', 'A2'};
cfg.method.cfg = [];

info1 = sleepdetection(cfg, info);

% visual feedback
sleepscoring(info1)

% n of slow waves
size(info1.score.marker(end).extra, 1)

% 6. detect spindles
cfg = [];
cfg.method.name = 'spindles';
cfg.method.fun = 'detect_spindle';
cfg.method.chan = 1:6;
cfg.method.epoch = {'NREM 2', 'NREM 3'};
cfg.method.ref = {'A1', 'A2'};

info1 = sleepdetection(cfg, info1);

% 7. PSD
cfg = [];
cfg.method.name = 'theta';
cfg.method.fun = 'compute_psd';
cfg.method.chan = 1:6;
cfg.method.epoch = {'REM'};
cfg.method.ref = {'A1', 'A2'};
cfg.method.cfg.freq = [4 8];

info1 = sleepdetection(cfg, info1);

cfg = [];
cfg.method.name = 'delta';
cfg.method.fun = 'compute_psd';
cfg.method.chan = 1:6;
cfg.method.epoch = {'NREM 2', 'NREM 3'};
cfg.method.ref = {'A1', 'A2'};
cfg.method.cfg.freq = [0.5 4];

info1 = sleepdetection(cfg, info1);

% get all the values
% [info1.score.marker(end).extra.psd]




% for-loop over participants
load /path/to/sleep_recording.mat

cfg = [];
cfg.method.name = 'slowwave';
cfg.method.fun = 'detect_slowwave';
cfg.method.chan = 1:6;
cfg.method.epoch = {'NREM 2', 'NREM 3'};
cfg.method.ref = {'A1', 'A2'};

info1 = sleepdetection(cfg, info);

% end for-loop


