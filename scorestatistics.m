function scorestatistics(varargin)
%SCORESTATISTICS compute statistics on the sleep scoring
%
% Use as:
%   scorestatistics(info) % one dataset
% or 
%   scorestatistics(info1, info2) % multiple datasets
% or 
%   scorestatistics('/path/to/sleepscoring.mat') % one dataset
% or 
%   scorestatistics('/path/to/sleepscoring.mat', '/path/to/csvfile.csv') % write to csvfile.csv
%
% Sleep is scored according to R&K or ASSM 2007.

%-------------------------------------%
%-check input
%-----------------%
%-check if the last input is a text file or directory
tocsv = false;
if ischar(varargin{end}) && ...
    ~strcmp(varargin{end}(end-3:end), '.mat')
  
  tocsv = true;
  csvfile = varargin{end};
  
  [~, ~, ext] = fileparts(csvfile);
  if strcmp(ext, '')
    fprintf('added extension ''csv''\n')
    csvfile = [csvfile '.csv'];
  end
  
  varargin(end) = [];

end
%-----------------%

%-----------------%
%-load from file
for i = 1:numel(varargin)
  
  if ischar(varargin{i})
    load(varargin{i}, 'info')
    varargin{i} = info;
    
  end
  
end
%-----------------%

%-----------------%
%-convert to new format
for i = 1:numel(varargin)
  varargin{i} = convert_score_cell2struct(varargin{i});
end
%-----------------%

%-----------------%
%-concatenate if necessary
if numel(varargin) == 1
  info = varargin{1};
else
  info = score_concat(varargin{:});
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-prepare input
opt = prepare_opt(info.optfile);
%-------------------------------------%

%-------------------------------------%
%-remove empty score, it's actually the default "not scored" usually
for r = 1:numel(info.score)
  info.score(r).stage(cellfun(@isempty, info.score(r).stage)) = {opt.stage(1).label};
end
%-------------------------------------%

%-------------------------------------%
%-report single rater
output = report_rater(info, opt.stage, tocsv);
if tocsv
  
  fid = fopen(csvfile, 'w+');
  fprintf(fid, output);
  fclose(fid);
  
  fprintf('writing score statistics to file %s\n', csvfile)
  
else
  fprintf(output)
end
%-------------------------------------%

%-------------------------------------%
%-interscore agreement
if ~tocsv
  report_comparison_raters(info.score, opt.stage);
end
%-------------------------------------%
