function cb_readplotdata(h0, eventdata)
%CB_READPLOTDATA: callback which reads data and plots them
%
% Called by
%  - cb_newinfo>cb_ok
%  - sleepscoring>cb_ff

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');
hdr = getappdata(0, 'hdr');

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
set(findobj('tag', 'epochnumber'), 'str', num2str(opt.epoch))
setappdata(0, 'opt', opt);
%-------%
%-----------------%

%-----------------%
%-read preallocated data or read from disk
tmp = getappdata(0, 'tmp');
if ~isempty(tmp) && tmp.epoch == opt.epoch
  dat = tmp.dat;
else
  dat = read_data(info, opt, hdr);
end
setappdata(0, 'dat', dat);
%-----------------%

%-----------------%
%-plot data
cb_plotdata()
plot_fft()
%-----------------%

%-----------------%
%-read data for following epoch
opt.epoch = opt.epoch + 1;
if opt.epoch > nepoch
  opt.epoch = nepoch;
end
tmp.epoch = opt.epoch;
tmp.dat = read_data(info, opt, hdr);
setappdata(0, 'tmp', tmp);
%-----------------%