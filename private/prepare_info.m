function info = prepare_info(info)
%PREPARE_INFO create complete info
% Input is info.dataset and info.cfgfile and optionally info.hdr
% The function will fill up all the other fields
%
% info
%  .cfgfile: file where the CFG is saved into
%  .dataset: full file name of the dataset
%  .hdr: header of the dataset read by ft_read_header
%  .fsample: sampling frequency taken from hdr
%  .beginrec: beginning of the recording in Matlab time (datenum)
%  .label: renamed labels
%  .score: prepare_score
%  .rater: index of the rater to use as reference
%
% TODO: either cfg or info

%-----------------%
%-read INFO first, if no dataset
if ~isfield(info, 'dataset')
  load(info.cfgfile, 'cfg')
  info = cfg;
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
% TODO: how to handle labels
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
set(findobj('tag', 'name_cfg'), 'str', info.cfgfile)
%-----------------%