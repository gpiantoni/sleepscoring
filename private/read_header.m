function [info, hdr] = read_header(info)


[~, ~, file_type] = fileparts(info.dataset);
if strcmpi(file_type, '.pseth'),
    psetObj = pset.load(info.dataset);
    hdr = get_meta(psetObj, 'hdr');
    hdr.nSamples = size(psetObj, 2);
    hdr.nTrials  = 1;
    hdr.label    = orig_labels(sensors(psetObj));
    info.hdr = hdr;
    info.fsample = psetObj.SamplingRate;
    info.label = hdr.label;    
    hdr.time_origin = get_time_origin(psetObj);
else
    hdr = ft_read_header(info.dataset);
    info.hdr = rmfield(hdr, 'orig'); % this is really large,  but it's needed by ft_read_data
    info.label = hdr.label;
end


end