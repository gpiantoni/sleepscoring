function cb_markertime(h, eventdata)
%CB_MARKERTIME print marker times for each
%
% Called by
%  - create_handles

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
score = info.score;

d = @(x) datestr(info.beginrec + x /60 /60 /24, 'HH:MM:SS');

r = info.rater;
fprintf('\t\tRATER: %s\n', score(r).rater)

for m = 1:numel(score(r).marker)
  fprintf('\nMARKER: %s\n', score(r).marker(m).name)
  
  if isempty(score(r).marker(m).time)
    fprintf('\t[No Markers]\n')
    
  else
    for i = 1:size(score(r).marker(m).time, 1)
      ep = ceil(mean(score(r).marker(m).time(i,:)) / score(r).wndw);
      
      fprintf('\t%s - %s \t(epoch% 4d %s)\n', ...
        d(score(r).marker(m).time(i,1)), d(score(r).marker(m).time(i,2)), ...
        ep, score(r).stage{ep});
    end
    
  end
end
