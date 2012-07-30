function cb_readplotdata(h, eventdata)
%CB_READPLOTDATA: callback which reads data and plots them

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

%-----------------%
%-data to read
%-------%
%-between boundaries
if opt.epoch < 1
  opt.epoch = 1;
end

nepoch = floor(cfg.hdr.nSamples / cfg.hdr.Fs / cfg.wndw);
if opt.epoch > nepoch
  opt.epoch = nepoch;
end
%-------%

%-------%
%-update epoch info
set(findobj('tag', 'epochnumber'), 'str', num2str(opt.epoch))
setappdata(0, 'opt', opt);
%-------%

begsample = (opt.epoch - 1) * cfg.wndw * cfg.hdr.Fs + opt.beginsleep * cfg.hdr.Fs;
endsample = begsample + cfg.wndw * cfg.hdr.Fs - 1;
%-----------------%

dat = readdata(cfg, opt, begsample, endsample);
setappdata(0, 'dat', dat);

cb_plotdata()
%-------------------------------------%