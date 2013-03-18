function cb_statistics(h, eventdata)
%CB_STATISTICS call scorestatistics to print overview on screen
%
% Called by
%  - create_handles

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
scorestatistics(info)
