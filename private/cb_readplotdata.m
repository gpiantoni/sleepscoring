function cb_readplotdata(h, eventdata)
%CB_READPLOTDATA: callback which reads data and plots them
%
% Called by
%  - cb_currentpoint
%  - cb_newinfo>cb_ok
%  - sleepscoring
%  - sleepscoring>cb_bb
%  - sleepscoring>cb_epoch
%  - sleepscoring>cb_ff

h0 = get_parent_fig(h);
info = getappdata(h0, 'info');
opt = getappdata(h0, 'opt');
hdr = getappdata(h0, 'hdr');

%-----------------%
%-data to read
%-------%
%-between boundaries
if opt.epoch < 1
  opt.epoch = 1;
end

if opt.epoch > info.score(info.rater).nepoch
  opt.epoch = info.score(info.rater).nepoch;
end
%-------%

%-------%
%-update epoch info
set(findobj(h0, 'tag', 'epochnumber'), 'str', num2str(opt.epoch))
setappdata(h0, 'opt', opt);
%-------%
%-----------------%

%-----------------%
%-read preallocated data or read from disk
tmp = getappdata(h0, 'tmp');
if ~isempty(tmp) && tmp.epoch == opt.epoch
  dat = tmp.dat;
else
  dat = read_data(info, opt, hdr);
end
setappdata(h0, 'dat', dat);
%-----------------%

%-----------------%
%-plot data
cb_plotdata(h0)
plot_fft(h0)
%-----------------%

%-----------------%
%-read data for following epoch
opt.epoch = opt.epoch + 1;
if opt.epoch > info.score(info.rater).nepoch
  opt.epoch = info.score(info.rater).nepoch;
end
tmp.epoch = opt.epoch;
tmp.dat = read_data(info, opt, hdr);
setappdata(h0, 'tmp', tmp);
%-----------------%