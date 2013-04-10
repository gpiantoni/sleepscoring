
cfg = [];
cfg.method.name = 'example';
cfg.method.fun = 'detect_example';
cfg.method.chan = 1:5:150;
cfg.method.ref = {'E94' 'E190'};
cfg.method.cfg.thr = 100;
cfg.method.Fhp = .3;

a = sleepdetection(cfg, info, opt, hdr);

sleepscoring(a, opt)