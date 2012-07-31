function cb_readplotdata(hObject, eventdata)
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

nepoch = floor(cfg.hdr.nSamples / cfg.fsample / cfg.score{3,cfg.rater});
if opt.epoch > nepoch
  opt.epoch = nepoch;
end
%-------%

%-------%
%-update epoch info
set(findobj('tag', 'epochnumber'), 'str', num2str(opt.epoch))
setappdata(0, 'opt', opt);
%-------%

wndw = cfg.score{3,cfg.rater};
beginrec = cfg.score{4,cfg.rater}(1);

begsample = (opt.epoch - 1) * wndw * cfg.fsample + beginrec * cfg.fsample;
endsample = begsample + wndw * cfg.fsample - 1;
%-----------------%

dat = readdata(cfg, opt, begsample, endsample);
setappdata(0, 'dat', dat);

cb_plotdata()

plotfft()
%-------------------------------------%