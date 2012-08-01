function score = prepare_score(score, rater, wndw)
%PREPARESCORE: even if empty, create score 

%-----------------%
%-score structure
% 1- score values
% 2- name of the rater
% 3- duration of scoring window
% 4- beginning and end of the scoring period (s)
% 5- artifacts (data not to analyze)
% 6- movements (?)
% 7- ?
% 8- ?
%-----------------%

if isstruct(score)
  
  %-------------------------------------%
  %-called by prepare_info, create empty structure
  info = score; % for clarity
  score = [];
  
  %-----------------%
  %-values from cb_rater or default
  if nargin < 3 % use default
    rater = [];
    wndw = 30; % default of 30s when showing the data the first time
  end
  %-----------------%
  
  nscore = floor(info.hdr.nSamples / info.fsample / wndw); % TODO: or ceil?
  
  score{1,1} = NaN(1, nscore);
  score{2,1} = rater;
  score{3,1} = wndw;
  score{4,1} = [1 info.hdr.nSamples] / info.fsample;
  score{5,1} = [];
  score{6,1} = [];
  score{7,1} = [];
  score{8,1} = [];
  %-------------------------------------%
  
else
  
  %-------------------------------------%
  %-called by score_retime
  dur = score{4,1}(2) - score{4,1}(1);
  nscore = floor(dur / score{3,1}); % TODO: or ceil?
  score{1,1} = NaN(1, nscore);
  %-------------------------------------%
  
end

