function out = read(filename)
% READ - Reads HRV statistics file
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
    data = textscan(fid, '%s\n',1);
    data = textscan(fid, '[^\n]');
catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

out = mjava.hash;
out(data{1}) = data{2};




end