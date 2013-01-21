function info = read(filename)
% READ - Reads WFDB-compatible annotation files
%
%
% info = read(filename)
%
%
% Where
%
% FILENAME is the full path of the file to read
%
% INFO is a data structure with fields:
%
% time      : The time instants of each annotation
%
% sample    : The sampling instants
%
% ann       : The annotation code
%
% subtyp    : The annotation subtype
%
% chan      : The channel number (or 0 if not applicable)
%
% num       : The num field
%
%
% ## References:
%
% [1] http://www.physionet.org/physiobank/annotations.shtml
%
%
% See also: wfdb

% Convert [] to quotes
filename2 = tempname;
perl('+misc/brackets2quotes.pl', filename, filename2);

filename = filename2;

fid = fopen(filename);

try
    data = textscan(fid, '%q %d %s %d %d %d');
catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

info.time   = data{1};
info.sample = data{2};
info.ann    = data{3};
info.subtyp = data{4};
info.chan   = data{5};
info.num    = data{6};

delete(filename);


end