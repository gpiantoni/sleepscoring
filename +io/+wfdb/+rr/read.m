function [rr, type] = read(filename)
% READ - Reads RR intervals file
%
%
%
%
% ## References:
%
% [1] http://www.physionet.org/tutorials/hrv/
%
% See also: wfdb

fid = fopen(filename);

try
    data = textscan(fid, '%f %s');
catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

rr   = data{1};
type = data{2};



end