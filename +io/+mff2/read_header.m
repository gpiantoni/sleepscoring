function hdr = read_header(filename)

% A minimalistic header

hdr.beginTime = perl('+io/+mff2/private/record_time.pl', filename);
hdr.signal = signal_info(filename);

end