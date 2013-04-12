
load /path/to/sleep_recording.mat

info = getappdata(gcf, 'info');
opt = getappdata(gcf, 'opt');
hdr = getappdata(gcf, 'hdr');


cfg = [];
cfg.method.name = 'example';
cfg.method.fun = 'detect_example';
cfg.method.chan = 1:5:150;
cfg.method.ref = {'E190'};
cfg.method.cfg.thr = 100;
cfg.method.Fhp = .3;

info1 = sleepdetection(cfg, info, opt, hdr);

sleepscoring(info1, opt)