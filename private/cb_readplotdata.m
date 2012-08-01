function cb_readplotdata(h0, eventdata)
%CB_READPLOTDATA: callback which reads data and plots them

info = getappdata(0, 'info');
opt = getappdata(0, 'opt');

%-----------------%
%-data to read
%-------%
%-between boundaries
if opt.epoch < 1
  opt.epoch = 1;
end

nepoch = numel(info.score{1,info.rater});
if opt.epoch > nepoch
  opt.epoch = nepoch;
end
%-------%

%-------%
%-update epoch info
set(findobj('tag', 'epochnumber'), 'str', num2str(opt.epoch))
setappdata(0, 'opt', opt);
%-------%
%-----------------%

%-----------------%
%-read data
dat = read_data(info, opt);
setappdata(0, 'dat', dat);
%-----------------%

%-----------------%
%-plot data
cb_plotdata()
plot_fft()
%-----------------%