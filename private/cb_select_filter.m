function cb_select_filter(h0, eventdata)
%CB_SELECT_FILTER specify filter settings

chantype = get(h0, 'label');

opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});
Fhp = opt.changrp(changrp).Fhp;
Flp = opt.changrp(changrp).Flp;

%-----------------%
%-popup
prompt = {'High-Pass Filter (Hz)' 'Low-Pass Filter (Hz)'};
name = ['Filter for ' chantype];
numlines = 1;
defaultanswer = {sprintf(' %1g', Fhp) sprintf(' %1g', Flp)};
answer = inputdlg(prompt, name, numlines, defaultanswer);

if ~isempty(answer) % cancel button
  
  %-------%
  %-highpass filter
  if ~isempty(answer{1})
    Fhp = textscan(answer{1}, '%f');
    opt.changrp(changrp).Fhp = Fhp{1};
  else
    opt.changrp(changrp).Fhp = [];
  end
  %-------%
  
  %-------%
  %-lowpass filter
  if ~isempty(answer{2})
    Flp = textscan(answer{2}, '%f');
    opt.changrp(changrp).Flp = Flp{1};
  else
    opt.changrp(changrp).Flp = [];
  end
  %-------%
  
  setappdata(0, 'opt', opt);
  cb_readplotdata()
  
end
%-----------------%