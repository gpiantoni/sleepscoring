function score = score_create(info, rater, wndw)
%SCORE_CREATE: create empty score
%-score structure, with fields
%  .stage: score values (cell with names)
%  .rater: name of the rater (string)
%  .window: duration of scoring window (scalar, s)
%  .score_beg: beginning of the scoring period (samples)
%  .score_end: end of the scoring period (samples)
%  .marker:
%    .name: name of marker (movement, arousal, artifact, etc)
%    .time: 2xN matrix with artifacts (s)

%-------------------------------------%
%-defaults
if isempty(rater); rater = ''; end
if isempty(wndw); wndw = 30; end
%-------------------------------------%

%-------------------------------------%
%-called by prepare_info, create empty structure
score = [];

score.rater = rater;
score.wdnw = wndw;
score.score_beg = 1;
score.score_end = info.hdr.nSamples;
score.marker = [];

nscore = floor(info.hdr.nSamples / info.fsample / wndw);
score.stage = cell(1, nscore);
%-------------------------------------%
