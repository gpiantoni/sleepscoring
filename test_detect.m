info = getappdata(gcf, 'info');

% for-loop over participants
load /path/to/sleep_recording.mat

cfg = [];
cfg.method.name = 'slowwave';
cfg.method.fun = 'detect_slowwave';
cfg.method.chan = 1:5:150;
cfg.method.ref = {'E190'};

info1 = sleepdetection(cfg, info);

% end for-loop


sleepscoring(info1, opt)