function info = prepare_info(info)
%PREPARE_INFO create info based on dataset
%
% Input is info.dataset and info.infofile and optionally info.hdr
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

%-----------------%
%-read INFO first, if no dataset
% The infofile work-around is bc sometimes you move the file in the
% different folder but this is not saved into the structure. Now it updates
% the location of the file with the new filename.
if ~isfield(info, 'dataset')
  infofile = info.file;
  load(infofile, 'info')
  info.infofile = infofile;
end
%-----------------%

%-----------------%
%-HDR (read it every time)
hdr = ft_read_header(info.dataset);
info.hdr = rmfield(hdr, 'orig'); % this is really large,  but it's needed by ft_read_data
setappdata(0, 'hdr', hdr)
%-----------------%

%-----------------%
%-FSAMPLE
% only for MFF at the moment
info.fsample = hdr.Fs;
%-----------------%

%-----------------%
%-BEGINREC
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
    info.score = hdr.orig.other.CRC.score;
    
  otherwise
    info.beginrec = 0;
    warning(['file format ' ft_filetype(info.dataset) ' not recognized. Time of the recording will not be correct'])
    
end
%-----------------%

%-----------------%
%-INFO
% use original labels, prepare_info_opt will change the labels
info.label = hdr.label;
%-----------------%

%-----------------%
%-SCORE
if ~isfield(info, 'score')
  info.score = prepare_score(info);
end
%-----------------%

%-----------------%
%-RATER
if ~isfield(info, 'rater')
  info.rater = 1;
end
%-----------------%

%-----------------%
%-INFO TEXT
set(findobj('tag', 'name_info'), 'str', info.infofile)

[~, filename] = fileparts(info.dataset);
set(findobj('tag', 'p_data'), 'title', filename)
%-----------------%