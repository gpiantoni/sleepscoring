function plotdata(cfg, opt, dat)


% All the options should be specified in opt
timescale = (opt.begsample:opt.endsample)/cfg.hdr.Fs;
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
  
  if ~isnan(score)
    i_score = [opt.stage.code] == score;
    ft_plot_box([ timescale([1 end]) -opt.scoreheight 0], 'FaceColor', opt.stage(i_score).color)
    ft_plot_text(timescale(end/2), 0, opt.stage(i_score).label)
  else
    ft_plot_box([ timescale([1 end]) -opt.scoreheight 0], 'FaceColor', 'white')
    ft_plot_text(timescale(end/2), 0, 'NOT SCORED')
  end
  
end
%-----------------%

%-----------------%
%-expand to full figure
set(gca,'Unit','normalized','Position',[0.09 0.1 .9 .9])
%-----------------%
