function scorestatistics(varargin)
%SCORESTATISTICS compute statistics on the sleep scoring
%
% Sleep is scored according to R&K or ASSM 2007.

%-------------------------------------%
%-check input

for i = 1:nargin
  
  if ischar(varargin{i})
    load(varargin{i}, 'info')
    varargin{i} = info;
  end
  
end

if nargin == 1
  info = varargin{1};
else
  info = concat_score(varargin{:});
end
%-------------------------------------%

%-------------------------------------%
%-prepare input
opt = prepare_opt(info.optfile);
%-------------------------------------%

%-------------------------------------%
%-report single rater
report_rater(info, opt.stage)
%-------------------------------------%

%-------------------------------------%
%-interscore agreement
report_comparison_raters(info.score, opt.stage);
%-------------------------------------%
