function cb_statistics(h0, eventdata)
%CB_STATISTICS call scorestatistics to print overview on screen

info = getappdata(0, 'info');
scorestatistics(info)
