function hypnogram(opt, score)
%HYPNOGRAM plot hypnogram, very similar to FASST
% Use as:
%  hypnogram(opt, score)
%
% OPT
%  .hypnogrid: distance of the grid in minutes (put a grid and label every ... minutes) 
%
%  .epoch: the epoch to highlight (optional)
%
%  .stage has subfields (see opt_default for more info)
%    .code: the number saved in score{1,1}
%    .label: the corresponding state
%    .color: the color used for plotting
%    .height: the height of the bar
%
% SCORE as one-column cell from FASST

hold on

%-----------------%
%-y axes
st_h = [opt.stage.height];
[st_h, sst_h] = sort(st_h);
set(gca, 'ytick', st_h, 'yticklabel', {opt.stage(sst_h).label})
%-----------------%

%-----------------%
%-x axes
xlim(score{4})
timetick = (1:floor(score{4}(2) / 60 / opt.hypnogrid)); % number of ticks
timetick_s = timetick * opt.hypnogrid * 60; % in seconds

%-grid
for i = 1:numel(timetick_s)
  plot(timetick_s(i) * [1 1], [st_h(1) st_h(end)], '--k')
end

%-xlabel
s2hhmm = @(x) datestr(x / 24 / 60 / 60, 'HH:MM'); % convert from seconds to HH:MM format
timelabel = cellfun(s2hhmm, num2cell(timetick_s), 'uni', 0);
set(gca, 'xtick', timetick_s, 'xticklabel', timelabel)
%-----------------%

%-----------------%
%-plot BAR for each stage
%plotbar as last because it covers the grid
for i = 1:numel(opt.stage)
  epochs = find(score{1,1} == opt.stage(i).code);
  
  if ~isempty(epochs)
    bar(epochs * score{3,1}, ones(size(epochs)) * opt.stage(i).height,  1, 'LineStyle', 'none', 'FaceColor', opt.stage(i).color)
  end
end
%-----------------%

%-----------------%
if isfield(opt, 'epoch')
  epochpos = [(opt.epoch - 0.5) * score{3,1} (opt.epoch + 0.5) * score{3,1}];
  xfill = [epochpos mean(epochpos)];
  yfill = st_h(end) + [1 1 0];
  fill(xfill, yfill, opt.arrowcolor)
end
%-----------------%

%-----------------%
%-expand to full figure
set(gca, 'Unit','normalized','Position',[0.05 0.1 .9 .9])
%-----------------%
