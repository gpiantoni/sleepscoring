function det = detect_example(cfg, data)
%DETECT_EXAMPLE example on how to set up a function for detection
%

if ~isfield(cfg, 'thr')
  cfg.thr = 100;
end

s = any(data.trial{1} > cfg.thr);

ds = diff(s);
b = [find(ds == 1)' find(ds == -1)'];
det = data.time{1}(b);
