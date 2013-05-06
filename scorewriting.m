function scorewriting(varargin)
%SCOREWRITING write the score for one rater to file
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
% It reports the scores in a table only for the rater specified in info.rater
% Before the table with scores, it reports the following information:
%   - name of the mat file
%   - name of the recording file
%   - date of the recording
%   - time of the recording
%   - name of the rater
%   - duration of the time window used for scoring
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
%-score to output
%-----------------%
if ~tocsv
  tab_size = 3;
  tab = @(x)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];
  sepa = '\n';
else
  tab = @(x)[x ','];
  sepa = ',';
end
%-----------------%

%-----------------%
%-header info
output = [info.infofile, sepa, info.dataset, sepa, ... 
  datestr(info.beginrec, 'dd-mmm-yyyy'), sepa, datestr(info.beginrec, 'HH:MM:SS'), sepa, ...
  info.score(info.rater).rater, sepa, sprintf('% 3d', info.score(info.rater).wndw), '\n'];
%-----------------%

%-----------------%
score = info.score(info.rater);

for i = 1:numel(score.stage)
  epoch_beg = info.beginrec + (score.score_beg + (i - 1) * score.wndw) /60 /60 /24;
  output = [output tab(datestr(epoch_beg, 'dd-mmm-yyyy')) ...
    tab(datestr(epoch_beg, 'HH:MM:SS')) tab(score.stage{i}) '\n'];
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-report single rater
if tocsv
  fid = fopen(csvfile, 'w+');
  fprintf(fid, output);
  fclose(fid);
  
  fprintf('writing score statistics to file %s\n', csvfile)
  
else
  fprintf(output)
  
end
%-------------------------------------%
