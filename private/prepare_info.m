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
if ~isfield(info, 'dataset')
  load(info.infofile, 'info')
end
%-----------------%

%-----------------%
%-HDR
if ~isfield(info, 'hdr')
  info.hdr = ft_read_header(info.dataset);
end
%-----------------%

%-----------------%
%-FSAMPLE
% only for MFF at the moment
info.fsample = info.hdr.Fs;
%-----------------%

%-----------------%
%-BEGINREC
% only for MFF at the moment
info.beginrec = datenum(info.hdr.orig.xml.info.recordTime([1:10 12:19]), 'yyyy-mm-ddHH:MM:SS');
%-----------------%

%-----------------%
%-INFO
% use original labels, prepare_info_opt will change the labels
info.label = info.hdr.label;
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