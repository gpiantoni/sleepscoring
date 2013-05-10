function cb_statistics(h, eventdata)
%CB_STATISTICS call scorestatistics to print overview on screen
%
% Called by
%  - create_handles

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');

if strcmp(get(h, 'label'), 'Score Statistics (to file) ...')
  
  [filename, pathname] = uiputfile('*.csv', 'Save Score Statistics to CSV File');
  if filename
    csvfile = fullfile(pathname, filename);
    scorestatistics(info, csvfile)
  end
  
else
  scorestatistics(info)
  
end

