function plot_data(info, opt, dat)
%PLOT_DATA actual plotting of the data
%
% Called by
%  - cb_plotdata

% All the options should be specified in opt
wndw = info.score(info.rater).wndw;
beginsleep = info.score(info.rater).score_beg;

epoch_beg = (opt.epoch - 1) * wndw + beginsleep; % add the beginning of the scoring period
epoch_end = epoch_beg + wndw - 1/info.fsample; % add length of time window and remove one sample
timescale = epoch_beg : 1/info.fsample : epoch_end;

p75 = 75 * ones(size(timescale));
d75 = -75 * ones(size(timescale));

chan = arrayfun(@(x) x.chan, opt.changrp, 'uni', 0);
chan = [chan{:}];

cnt = 0;
label = [];

axes(opt.h.axis.data) % needs to be called inside, otherwise it does not work
delete(findobj(opt.h.axis.data, 'tag', 'data'))

for i = 1:numel(opt.changrp)
  
  linecolor = opt.changrp(i).linecolor;
  
  for c = opt.changrp(i).chan
    
    chanindx = ismember(chan, c);
    
    cnt = cnt + 1;
    hv = ft_plot_vector(timescale, dat(chanindx,:), 'color', linecolor, ...
      'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt); % with height you can control distance between lines
    set(hv, 'tag', 'data')
    
    %-----------------%
    %-line at zero
    if opt.grid0
      hv = ft_plot_vector(timescale, zeros(size(timescale)), 'color', linecolor, 'style', ':', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
      set(hv, 'tag', 'data')
    end
    %-----------------%
    
    %-----------------%
    %- +/- 75uV grid
    if strcmp(opt.changrp(i).chantype, 'eeg') && opt.grid75
      hv = ft_plot_vector(timescale, p75, 'color', linecolor, 'style', '--', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
      set(hv, 'tag', 'data')
      hv = ft_plot_vector(timescale, d75, 'color', linecolor, 'style', '--', ...
        'height', 2, 'vlim', opt.ylim, 'vpos', -1 * cnt);
      set(hv, 'tag', 'data')
    end
    %-----------------%
    
  end
  
  label = [label opt.changrp(i).chan];
  
end

%-----------------%
%-x axes
xlim(timescale([1 end]))
xspan = info.fsample * opt.timegrid;
xgrid = timescale([1:xspan:end]);
s2hhmm = @(x) datestr(x / 24 / 60 / 60 + info.beginrec, 'HH:MM:SS'); % convert from seconds to HH:MM format
timelabel = cellfun(s2hhmm, num2cell(xgrid), 'uni', 0);
set(opt.h.axis.data, 'xtick', xgrid, 'xticklabel', timelabel)
%-----------------%

%-----------------%
%-y axes
axes_ylim = [-1 * (cnt+1) 0];
ylim(axes_ylim)
set(opt.h.axis.data, 'ytick', axes_ylim(1)+1:axes_ylim(2)-1, 'yticklabel', label(end:-1:1))
%-----------------%

%-----------------%
%-1s grid
if opt.grid1s
  for s = timescale(1):timescale(end)
    line([1 1] * s, axes_ylim, 'linestyle', ':', 'color', 'k')
  end
end
%-----------------%

%-----------------%
%-plot score on top
if ~isempty(info.score(info.rater).rater)
  
  stages = {opt.stage.label};
  score = info.score(info.rater).stage{opt.epoch};
  
  if isempty(score)
    score = stages(1); % default
  end
  i_score = strcmp(stages, score);
  
  ft_plot_box([timescale([1 end]) -opt.scoreheight 0], 'FaceColor', opt.stage(i_score).color)
  
end
%-----------------%

%-----------------%
%-expand to full figure
set(opt.h.axis.data, 'Unit', 'normalized', 'Position', [0.09 0.1 .9 .9])
%-----------------%
