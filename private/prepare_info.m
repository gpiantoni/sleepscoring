function [info hdr] = prepare_info(info)
%PREPARE_INFO create info based on dataset
%
% Input is info.dataset and info.infofile
% The function will fill up all the other fields
%
% info
%  .infofile: file where the info is saved into
%  .dataset: full file name of the dataset
%  .hdr: header of the dataset read by ft_read_header
%  .fsample: sampling frequency taken from hdr
%  .beginrec: beginning of the recording in Matlab time (datenum)
%  .label: renamed labels
%  .score: prepare_score
%  .rater: index of the rater to use as reference
%
% This function is always followed by prepare_info_opt, which takes the
% input from info and opt, and uses them together
%
% Called by
%  - cb_newinfo
%  - sleepscoring
%  - sleepscoring>cb_openinfo

%-----------------%
%-read INFO first, if no dataset
if ~isfield(info, 'dataset')
    
    %-------%
    %-check if it exists
    isinfo = whos('-file', info.infofile, 'info');
    if isempty(isinfo)
        error('there is no variable called ''info'', this does not seem a valid sleepscoring file')
    end
    %-------%
    
    %-------%
    %-The infofile work-around is bc sometimes you move the file in the
    % different folder but this is not saved into the structure. Now it updates
    % the location of the file with the new filename.
    infofile = info.infofile;
    load(infofile, 'info')
    info.infofile = infofile;
    %-------%
    
    info = prepare_log(info, 'openinfo');
    
else
    info = prepare_log(info, 'newinfo');
    
end
%-----------------%

%-----------------%
%-force .mat extension
[path name ext] = fileparts(info.infofile);

if ~strcmp(ext, '.mat')
    
    if strcmp(ext, '')
        fprintf('Appending extension .mat to file\n')
    else
        fprintf('Changing extension from %s to .mat\n', ext)
    end
    
    ext = '.mat'; % force extension to be mat
    info.infofile = fullfile(path, [name ext]);
    
end
%-----------------%

%-----------------%
%-check if dataset exists or find one similar
info = find_dataset(info);
%-----------------%

%-----------------%
%-HDR (read it every time)
% my hack for .pset/.pseth files
[info, hdr] = read_header(info);
%-----------------%

%-----------------%
%-BEGINREC

% .pset/.pseth are not recognized by Fieldtrip
[~, ~, ext] = fileparts(info.dataset);
if strcmpi(ext, '.pseth')
    info.beginrec = hdr.time_origin;
else    
    switch ft_filetype(info.dataset)
        
        case 'egi_mff'
            %-with MFF file, read directly from xml
            info.beginrec = datenum(hdr.orig.xml.info.recordTime([1:10 12:19]), 'yyyy-mm-ddHH:MM:SS');
            
        case 'spmeeg_mat'
            %-with FASST data, read from FASST
            if isfield(hdr.orig.other, 'info') && isfield(hdr.orig.other.info, 'date')
                
                info.beginrec = datenum(hdr.orig.other.info.date(1), hdr.orig.other.info.date(2), hdr.orig.other.info.date(3), ...
                    hdr.orig.other.info.hour(1), hdr.orig.other.info.hour(2), hdr.orig.other.info.hour(3));
                
            else
                info.beginrec = 0;
                warning('not time information in the FASST file')
                
            end
            
            %-read score as well from FASST
            if ~isfield(info, 'score')
                info.score = hdr.orig.other.CRC.score;
            end
            
        case 'edf'
            if isfield(hdr, 'orig') && isfield(hdr.orig, 'T0') && numel(hdr.orig.T0) == 6
                info.beginrec = datenum(hdr.orig.T0);
                
            else
                info.beginrec = 0;
                warning(['file format EDF does not have a valid T0 field to reconstruct the time of the recording'])
                
            end
            
        otherwise
            info.beginrec = 0;
            warning(['file format ' ft_filetype(info.dataset) ' not recognized. Time of the recording will not be correct'])
    end
end
%-----------------%

%-----------------%
%-SCORE
if ~isfield(info, 'score')
   info.score = score_create(info, [], []);
end
%-----------------%

%-----------------%
%-RATER
if ~isfield(info, 'rater')
  info.rater = 1;
end
%-----------------%