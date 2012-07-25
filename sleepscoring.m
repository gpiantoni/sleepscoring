function sleepscoring(cfg)
%TODO:
% - powerspectrum
% - modify scoring
% - multiple windows
% - automatic detection of SW and spindles
% - automatic scoring
% - shortcuts
% - read time from hdr-orig
% - The beginning of the sleep scoring need not coincide with the beginning
% of the recordings (fix cb_currentpoint as well)
% - save cfg/score (and info panel should show: saving info in...)

%-------------------------------------%
h = findobj('tag', 'sleepscoring');
if h
  delete(h)
end

h = figure;
set(h, 'tag', 'sleepscoring')
%-------------------------------------%

%-------------------------------------%
%-CFG input options (user-specific)
addpath([fileparts(mfilename('fullpath')) filesep 'preference'])

cfg.default.chan = 'channame';
cfg.default.opt = 'opt_default'; % function with opt 
%-------------------------------------%

%-------------------------------------%
%-CFG: stable info
setappdata(0, 'cfg', cfg)
%-------------------------------------%

%-------------------------------------%
%-OPT: preferences
opt = feval(cfg.default.opt);
setappdata(0, 'opt', opt)
%-------------------------------------%

%-------------------------------------%
%-PANELS
%-----------------%
%-create panels
uipanel('Title', 'Sleep Data', 'FontSize', 12, 'tag', 'p_data', ... % rename with name of subject
  'BackgroundColor','white', ...
  'Position', [opt.marg_l opt.marg_u opt.width_l opt.height_u]);

uipanel('Title', 'Hypnogram', 'FontSize', 12, 'tag', 'p_hypno',...
  'BackgroundColor','white', ...
  'Position', [opt.marg_l opt.marg_d opt.width_l opt.height_d]);

uipanel('Title', 'Information', 'FontSize', 12, 'tag', 'p_info',...
  'Position', [opt.marg_r opt.marg_u opt.width_r opt.height_u]);

uipanel('Title', 'PowerSpectrum', 'FontSize', 12, 'tag', 'p_fft', ...
  'BackgroundColor','white', ...
  'Position', [opt.marg_r opt.marg_d opt.width_r opt.height_d]);
%-----------------%

%-----------------%
uicontrol(findobj('tag', 'p_info'), 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .5 .4 .1], 'str', '<<', ...
  'call', @cb_bb);
uicontrol(findobj('tag', 'p_info'), 'sty', 'push', 'uni', 'norm', ...
  'pos', [.55 .5 .4 .1], 'str', '>>', ...
  'call', @cb_ff);

uicontrol(findobj('tag', 'p_info'), 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .35 .4 .1], 'str', '+', ...
  'call', @cb_yu);
uicontrol(findobj('tag', 'p_info'), 'sty', 'push', 'uni', 'norm', ...
  'pos', [.55 .35 .4 .1], 'str', '-', ...
  'call', @cb_yd);

uicontrol(findobj('tag', 'p_info'), 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.05 .2 .4 .1], 'str', '75uV', ...
  'val', opt.grid75, 'call', @cb_grid75);

uicontrol(findobj('tag', 'p_info'), 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.55 .2 .4 .1], 'str', '1s', ...
  'val', opt.grid1s, 'call', @cb_grid1s);
%-----------------%  
%-------------------------------------%

%-------------------------------------%
%-Menu bar
set(h, 'Menubar', 'none')
m_file = uimenu(h, 'label', 'File');
uimenu(m_file, 'label', 'Load MFF', 'call', @cb_loadmff);

m_chan = uimenu(h, 'label', 'Channel Selection');
for i = 1:numel(opt.changrp)
  uimenu(m_chan, 'label', opt.changrp(i).chantype, 'call', @cb_selchan);
end

m_filt = uimenu(h, 'label', 'Filter');
for i = 1:numel(opt.changrp)
  uimenu(m_filt, 'label', opt.changrp(i).chantype, 'call', @cb_filt);
end

m_ref = uimenu(h, 'label', 'Reference');
for i = 1:numel(opt.changrp)
  uimenu(m_ref, 'label', opt.changrp(i).chantype, 'call', @cb_ref);
end

m_score = uimenu(h, 'label', 'Sleep Score');
uimenu(m_score, 'label', 'New Score', 'call', @cb_newrater)
uimenu(m_score, 'label', 'Load Score', 'call', @cb_loadscore)
uimenu(m_score, 'label', 'Import Score from FASST', 'call', @cb_importscore)
uimenu(m_score, 'label', 'Rater', 'Sep', 'on', 'tag', 'uimenu_rater', 'enable', 'off')
uimenu(m_score, 'label', 'New Rater', 'call', @cb_newrater)
%-------------------------------------%

%-------------------------------------%
%-read the data if present in cfg
if isfield(cfg, 'dataset') 
  if ~isfield(cfg, 'hdr')
    cfg.hdr = ft_read_header(cfg.dataset);
  end

  [cfg opt] = sleepscoring_init(cfg, opt);
  setappdata(0, 'cfg', cfg)
  setappdata(0, 'opt', opt)
  
  cb_readplotdata
end
%-------------------------------------%

%-------------------------------------%
%-get point
set(h, 'windowbuttonDownFcn', @cb_currentpoint)
%-------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%-------------------------------------%
%-callback: load dataset
function cb_loadmff(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
dirname = uigetdir;

if exist(dirname, 'dir')
  cfg.dataset = dirname;
  cfg.hdr = ft_read_header(dirname);
end
setappdata(0, 'cfg', cfg)

[~, filename] = fileparts(dirname);
set(findobj('tag', 'p_data'), 'Title', filename)

[cfg opt] = sleepscoring_init(cfg);
setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)

cb_readplotdata
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_selchan(h, eventdata)

chantype = get(h, 'label');

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

%-don't show labels belonging to another chantype
nolabel = arrayfun(@(x) x.chan, opt.changrp(~changrp), 'uni', 0);
nolabel = [nolabel{:}];
[~, ilabel] = setdiff(cfg.label, nolabel);
label = cfg.label(sort(ilabel));

[~, chanindx] = intersect(label, opt.changrp(changrp).chan);
chanindx = select_channel_list(label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).chan = label(chanindx)';

setappdata(0, 'opt', opt);

cb_readplotdata
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_ref(h, eventdata)

chantype = get(h, 'label');

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(cfg.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(cfg.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = cfg.label(chanindx)';

setappdata(0, 'opt', opt);

cb_readplotdata
%-------------------------------------%

%-------------------------------------%
%-callback: filter information
function cb_filt(h, eventdata)

chantype = get(h, 'label');

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
  if ~isempty(answer{1})
    Fhp = textscan(answer{1}, '%f');
    opt.changrp(changrp).Fhp = Fhp{1};
  else
    opt.changrp(changrp).Fhp = [];
  end
  
  if ~isempty(answer{2})
    Flp = textscan(answer{2}, '%f');
    opt.changrp(changrp).Flp = Flp{1};
  else
    opt.changrp(changrp).Flp = [];
  end
  
  setappdata(0, 'opt', opt);
  
  cb_readplotdata
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_loadscore(h, eventdata)

%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_importscore(h, eventdata)
%TODO: indicate that this will overwrite current score
%TODO: check that the length is consistent

[filename, pathname] = uigetfile('*.mat', 'Select FASST file');
warning off % class to struct warning
load([pathname filename], 'D')
warning on

cfg = getappdata(0, 'cfg');
if isfield(D.other, 'CRC') && isfield(D.other.CRC, 'score')
  cfg.score = D.other.CRC.score;
end
cfg.rater = 1;

setappdata(0, 'cfg', cfg)
update_rater()
%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_newrater(h, eventdata)

%-----------------%
cfg = getappdata(0, 'cfg');
if isempty(cfg.score)
  newrater = 1;
else
  newrater = size(cfg.score,2) + 1;
end
%-----------------%

%-----------------%
%-prompt
prompt = {'Rater Name' 'Window Duration'};
name = 'Sleep Score Information';
defaultanswer = {'' '30'};
answer = inputdlg(prompt, name, 1, defaultanswer);

wndw = textscan(answer{2}, '%f');
wndw = wndw{1};
%-----------------%

%-----------------%
%-score structure
% 1- score values
% 2- name of the rater
% 3- duration of scoring window
% 4- beginning and end of the scoring period (s)
% 5- artifacts (data not to analyze)
% 6- movements (?)
% 7- empty (will contain the markers)
nscore = ceil(cfg.hdr.nSamples / cfg.hdr.Fs / wndw);
cfg.score{1,newrater} = NaN(1, nscore);
cfg.score{2,newrater} = answer{1};
cfg.score{3,newrater} = wndw;
cfg.score{4,newrater} = [1 cfg.hdr.nSamples] / cfg.hdr.Fs;
cfg.score{5,newrater} = [];
cfg.score{6,newrater} = [];
cfg.score{7,newrater} = [];
%-----------------%

%-----------------%
%-update cfg
cfg.rater = newrater;
setappdata(0, 'cfg', cfg)
update_rater()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: go back
function cb_bb(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
opt.begsample = opt.begsample - cfg.wndw * cfg.hdr.Fs;
opt.endsample = opt.endsample - cfg.wndw * cfg.hdr.Fs;
opt.epoch = opt.epoch - 1;

if opt.begsample <= 0 
  opt.begsample = 1; % TODO: should be manually-specified beginning of the recording
  opt.endsample = opt.begsample + cfg.hdr.Fs * cfg.wndw - 1;
end

setappdata(0, 'opt', opt);
cb_readplotdata;
%-------------------------------------%

%-------------------------------------%
%-callback: go forward
function cb_ff(h, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');
opt.begsample = opt.begsample + cfg.wndw * cfg.hdr.Fs;
opt.endsample = opt.endsample + cfg.wndw * cfg.hdr.Fs;
opt.epoch = opt.epoch + 1;

if opt.endsample > cfg.hdr.nSamples * cfg.hdr.nTrials
  opt.endsample = cfg.hdr.nSamples * cfg.hdr.nTrials;
  opt.begsample = cfg.endsample - cfg.hdr.Fs * cfg.wndw + 1; % TODO: should be manually-specified end of the recording (in 30s epochs)
end
setappdata(0, 'opt', opt);
cb_readplotdata
%-------------------------------------%

%-------------------------------------%
%-callback: smaller scale
function cb_yu(h, eventdata)
opt = getappdata(0, 'opt');
opt.ylim = opt.ylim / 1.1;
setappdata(0, 'opt', opt);
cb_plotdata
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_yd(h, eventdata)
opt = getappdata(0, 'opt');
opt.ylim = opt.ylim * 1.1;
setappdata(0, 'opt', opt);
cb_plotdata
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid75(h, eventdata)
opt = getappdata(0, 'opt');

opt.grid75 = ~opt.grid75;
setappdata(0, 'opt', opt);
set(findobj('str', '75uV'), 'val', opt.grid75)
cb_plotdata
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid1s(h, eventdata)
opt = getappdata(0, 'opt');

opt.grid1s = ~opt.grid1s;
setappdata(0, 'opt', opt);
set(findobj('str', '1s'), 'val', opt.grid1s)
cb_plotdata
%-------------------------------------%
%---------------------------------------------------------%