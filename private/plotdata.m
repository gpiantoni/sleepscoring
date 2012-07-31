function plotdata(cfg, opt, dat)

% All the options should be specified in opt
wndw = cfg.score{3,cfg.rater};
beginsleep = cfg.score{4,cfg.rater}(1);

epoch_beg = (opt.epoch - 1) * wndw + beginsleep; % add the beginning of the scoring period
epoch_end = epoch_beg + wndw - 1/cfg.fsample; % add length of time window and remove one sample
timescale = epoch_beg : 1/cfg.hdr.Fs : epoch_end;

p75 = 75 * ones(size(timescale));
d75 = -75 * ones(size(timescale));

chan = arrayfun(@(x) x.chan, opt.changrp, 'uni', 0);
chan = [chan{:}];

cnt = 0;
label = [];
for i = 1:numel(opt.changrp)
  
  linecolor = opt.changrp(i).linecolor;
  
  for c = opt.changrp(i).chan
    
    chanindx = ismember(chan, c);
    
    cnt = cnt + 1;
    ft_plot_vector(timescale, dat(chanindx,:), 'color', linecolor, ...
      'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt); % with height you can control distance between lines
    
    %-----------------%
    %-line at zero
    if opt.grid0
      ft_plot_vector(timescale, zeros(size(timescale)), 'color', linecolor, 'style', ':', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
    end
    %-----------------%
    
    %-----------------%
    %- +/- 75uV grid
    if strcmp(opt.changrp(i).chantype, 'eeg') && opt.grid75
      ft_plot_vector(timescale, p75, 'color', linecolor, 'style', '--', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
      ft_plot_vector(timescale, d75, 'color', linecolor, 'style', '--', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
    end
    %-----------------%
    
  end
  
  label = [label opt.changrp(i).chan];  
  
end

%-----------------%
%-x axes
xlim(timescale([1 end]))
xspan = cfg.hdr.Fs * opt.timegrid;
xgrid = timescale([1:xspan:end]);
s2hhmm = @(x) datestr(x / 24 / 60 / 60 + cfg.beginrec, 'HH:MM:SS'); % convert from seconds to HH:MM format
timelabel = cellfun(s2hhmm, num2cell(xgrid), 'uni', 0);
set(gca, 'xtick', xgrid, 'xticklabel', timelabel)
%-----------------%

%-----------------%
%-y axes
axes_ylim = [-1 * (cnt+1) 0];
ylim(axes_ylim)
set(gca, 'ytick', axes_ylim(1)+1:axes_ylim(2)-1, 'yticklabel', label(end:-1:1))
%-----------------%

%-----------------%
%- 1s grid
if opt.grid1s
  for s = timescale(1):timescale(end)
    line([1 1] * s, axes_ylim, 'linestyle', ':', 'color', 'k')
  end
end
%-----------------%

%-----------------%
%-plot score on top
if ~isempty(cfg.score)
  score = cfg.score{1,cfg.rater}(opt.epoch);
  
  i_score = find([opt.stage.code] == score);
  if isempty(i_score)
    i_score = find(isnan([opt.stage.code]));
  end
  
 ft_plot_box([timescale([1 end]) -opt.scoreheight 0], 'FaceColor', opt.stage(i_score).color)
  
end
%-----------------%

%-----------------%
%-expand to full figure
set(gca,'Unit','normalized','Position',[0.09 0.1 .9 .9])
%-----------------%
