function cb_readplotdata(h, eventdata)
%CB_READPLOTDATA: callback which reads data and plots them

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

%-----------------%
%-data to read
set(findobj('tag', 'epochnumber'), 'str', num2str(opt.epoch))

begsample = (opt.epoch - 1) * cfg.wndw * cfg.hdr.Fs + opt.recbegin * cfg.hdr.Fs;
endsample = begsample + cfg.wndw * cfg.hdr.Fs - 1;
%TODO: check it's not outside the limit
%-----------------%

dat = readdata(cfg, opt, begsample, endsample);
setappdata(0, 'dat', dat);

cb_plotdata()
%-------------------------------------%