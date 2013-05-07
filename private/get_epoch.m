function epoch = get_epoch(info, opt)
%GET_EPOCH find epochs with markers
%
% Called by
%  - enable_marker
%  - create_handles>cb_marker
%  - create_handles>cb_mbb
%  - create_handles>cb_mff

wndw = info.score(info.rater).wndw;
beginsleep = info.score(info.rater).score_beg;

if isempty(info.score(info.rater).marker) || ...
    isempty(info.score(info.rater).marker(opt.marker.i).time)
  epoch = [];
  return
end

begmarker = info.score(info.rater).marker(opt.marker.i).time(:,1);

epoch = (begmarker - beginsleep) / wndw + 1;
epoch = unique(floor(epoch));
