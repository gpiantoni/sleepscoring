function score = score_create(info, rater, wndw)
%SCORE_CREATE: create empty score
% score structure, with fields
%  .stage: score values (cell with names)
%  .rater: name of the rater (string)
%  .window: duration of scoring window (scalar, s)
%  .score_beg: beginning of the scoring period (s)
%  .score_end: end of the scoring period (s)
%  .marker:
%    .name: name of marker (movement, arousal, artifact, etc)
%    .time: 2xN matrix with marker (s)
%
% Called by
%  - prepare_info
%  - cb_rater

%-------------------------------------%
%-defaults
if isempty(wndw); wndw = 30; end
%-------------------------------------%

%-------------------------------------%
%-called by prepare_info, create empty structure
score = [];

score.rater = rater; % can be empty
score.wndw = wndw;
score.score_beg = 1 / info.fsample;
score.score_end = info.hdr.nSamples / info.fsample;
score.marker = [];

score.nepoch = floor((score.score_end - score.score_beg) / wndw);
score.stage = cell(1, score.nepoch);
%-------------------------------------%
