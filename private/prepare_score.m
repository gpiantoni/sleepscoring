function score = prepare_score(score)
%PREPARESCORE: even if empty, create score 
% INPUT can be
%  - empty: so initialize

%-----------------%
%-score structure
% 1- score values
% 2- name of the rater
% 3- duration of scoring window
% 4- beginning and end of the scoring period (s)
% 5- artifacts (data not to analyze)
% 6- movements (?)
% 7- empty (will contain the markers)
%-----------------%

%-------------------------------------%
%-called by prepare_info, create empty structure
if isstruct(score)
  
  info = score; % for clarity
  score = [];
  wndw = 30; % default of 30s when showing the data the first time
  
  nscore = floor(info.hdr.nSamples / info.fsample / wndw); % TODO: or ceil?
  
  score{1,1} = NaN(1, nscore);
  score{2,1} = [];
  score{3,1} = wndw;
  score{4,1} = [1 info.hdr.nSamples] / info.fsample;
  score{5,1} = [];
  score{6,1} = [];
  score{7,1} = [];
  
end
%-------------------------------------%
