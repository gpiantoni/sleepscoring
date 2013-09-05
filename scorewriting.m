function scorewriting(varargin)
%SCOREWRITING write the score for one rater to file
%
% Use as:
%   scorewriting(info) % one dataset
% or 
%   scorewriting(info1, info2) % multiple datasets
% or 
%   scorewriting('/path/to/sleepscoring.mat') % one dataset
% or 
%   scorewriting(info, '/path/to/csvfile.csv') % write to csvfile.csv
% or 
%   scorewriting(info, 'Jennifer') % score for specified rater,
%                                       otherwise it uses the default
%
% You can pass the arguments in any order.
% 
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
%-check if input contains csvfile or name of the rater
tocsv = false;
rater_name = [];

is_csv = @(x) ischar(x) && strcmp(x(end-3:end), '.csv');
where_csv = cellfun(is_csv, varargin);
is_rater = @(x) ischar(x) && ~strcmp(x(end-3:end), '.mat');
where_rater = cellfun(is_rater, varargin) & ~where_csv; % "& ~where_csv" means that we should not consider the csv file either

if any(where_csv)
  tocsv = true;
  csvfile = varargin{where_csv};
end  

if any(where_rater)
  rater_name = varargin{where_rater};
end  

varargin = varargin(~(where_csv | where_rater));
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
%-prepare opt
opt = prepare_opt(info.optfile);
%-------------------------------------%

%-------------------------------------%
%-remove empty score, it's actually the default "not scored" usually
for r = 1:numel(info.score)
  info.score(r).stage(cellfun(@isempty, info.score(r).stage)) = {opt.stage(1).label};
end
%-------------------------------------%

%-------------------------------------%
%-select rater if it exists
if ~isempty(rater_name)
  rater = find(strcmp({info.score.rater}, rater_name));
  if isempty(rater)
    rater = info.rater;
    warning('could not find "%s" among raters %s. Using default "%s"', ...
      rater_name, sprintf(' "%s"', info.score.rater), info.score(info.rater).rater);
  end
  
else
  if ~isfield(info, 'rater')
    error('Specify the name of the rater (%s)', ...
      sprintf(' %s', info.score.rater))
  end
  rater = info.rater;
  
end
%-------------------------------------%

%-------------------------------------%
%-score to output
%-----------------%
if ~tocsv
  tab_size = 3;
  tab = @(x)[x repmat('\t', 1, tab_size - floor(numel(x)/8))];

else
  tab = @(x)[x ','];

end
%-----------------%

%-----------------%
%-header info
[rec_dur, rec_time] = calculate_rec_time(info, opt.stage);

output = [tab('info file') info.infofile '\n' ...
  tab('dataset') info.dataset  '\n' ...
  tab('recording start date') datestr(info.beginrec, 'dd-mmm-yyyy')  '\n' ...
  tab('recording start time') datestr(info.beginrec, 'HH:MM:SS')  '\n' ...
  tab('rater') info.score(rater).rater  '\n' ...
  tab('scoring window length') sprintf('% 2ds', info.score(rater).wndw)  '\n' ...
  tab('Lights off') datestr(rec_time(1,rater)/24 /60 /60, 'HH:MM:SS') '\n' ...
  tab('Lights on') datestr(rec_time(2,rater)/24 /60 /60, 'HH:MM:SS') '\n\n'];
%-----------------%

%-----------------%
score = info.score(rater);

for i = 1:numel(score.stage)
  epoch_beg = info.beginrec + (score.score_beg + (i - 1) * score.wndw) /60 /60 /24;
  output = [output tab(datestr(epoch_beg, 'dd-mmm-yyyy')) ...
    tab(datestr(epoch_beg, 'HH:MM:SS')) score.stage{i} '\n'];
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
