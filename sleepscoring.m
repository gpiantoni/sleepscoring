function sleepscoring(cfg)
%SLEEPSCORING do sleep scoring on EGI data
% This function takes one optional CFG argument. If no input, go to
% "File" >> "Load MFF" and select the .mff folder with the sleep data.
% To start a new sleep score, go to "Sleep Score" >> "New Score" and add
% the relevant information.
% 
% The optional CFG input argument has the following fields:
%   .dataset: the absolute path to the MFF file
%   .hdr: the header of the MFF file (use ft_read_header). If .hdr is not
%         present, it'll be read from .dataset
%
%   .default.channame: if you want to rename some channels, you can use
%                      this function. By default, it uses CHANNAME. You can
%                      use any other function, based on channame.m
%
%   .default.opt: all the optional information, for example the default
%                 channels and visualization properties. By default, it
%                 uses OPT_DEFAULT. If you want to edit the optional
%                 information, create a new file based on "opt_default.m"
%                 and change the parameter. Then .default.opt should
%                 contain the name of the new file.
%  
% SLEEPSCORING can only run in one window at the time. If you want to run
% two sessions at the same time, open a new Matlab.
%    

%TODO:
% - powerspectrum
% - marker (beginning of recordings: are you sure you want to modify sleep scoring?)
% - multiple windows
% - automatic detection of SW and spindles
% - automatic scoring
% - shortcuts
% - The beginning of the sleep scoring need not coincide with the beginning
% of the recordings (fix cb_currentpoint as well)
% - save cfg/score (and info panel should show: saving info in...)
% - when sleep scoring, enter beginning of sleep

%---------------------------------------------------------%
%-GUI FUNCTION
%---------------------------------------------------------%

%-------------------------------------%
%-CFG input options (user-specific)
addpath([fileparts(mfilename('fullpath')) filesep 'preference'])

if nargin == 0
  cfg = [];
end

cfg.default = ft_getopt(cfg, 'default', []);
cfg.default.chan = ft_getopt(cfg.default, 'chan', 'channame');
cfg.default.opt = ft_getopt(cfg.default, 'opt', 'opt_default');
%-------------------------------------%

%-------------------------------------%
%-OPT: preferences
opt = feval(cfg.default.opt);
%-------------------------------------%

%-------------------------------------%
%-create new figure
h = findobj('tag', 'sleepscoring');
if h; delete(h); end
opt.h.main = figure;
set(opt.h.main, 'tag', 'sleepscoring')
%-------------------------------------%

%-------------------------------------%
%-PANELS
%-----------------%
%-create main panels
opt.h.data = uipanel('Title', 'Sleep Data', 'FontSize', 12, 'tag', 'p_data', ... % rename with name of subject
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.u opt.width.l opt.height.u]);

opt.h.hypno = uipanel('Title', 'Hypnogram', 'FontSize', 12, 'tag', 'p_hypno',...
  'BackgroundColor','white', ...
  'Position', [opt.marg.l opt.marg.d opt.width.l opt.height.d]);

opt.h.info = uipanel('Title', 'Information', 'FontSize', 12, 'tag', 'p_info',...
  'Position', [opt.marg.r opt.marg.u opt.width.r opt.height.u]);

opt.h.fft = uipanel('Title', 'PowerSpectrum', 'FontSize', 12, 'tag', 'p_fft', ...
  'BackgroundColor','white', ...
  'Position', [opt.marg.r opt.marg.d opt.width.r opt.height.d]);

%-------%
%-create axes
opt.axis.data = axes('parent', opt.h.data, 'vis', 'off');
opt.axis.hypno = axes('parent', opt.h.hypno, 'vis', 'off');
opt.axis.fft = axes('parent', opt.h.fft, 'vis', 'off');
%-------%
%-----------------%

%-----------------%
%-create button and various items in the information panel
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .5 .25 .1], 'str', '<<', ...
  'call', @cb_bb);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .5 .30 .1], 'str', '', 'tag', 'epochnumber', ...
  'call', @cb_epoch); 
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .5 .25 .1], 'str', '>>', ...
  'call', @cb_ff);

uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.05 .35 .25 .1], 'str', '+', ...
  'call', @cb_yu);
uicontrol(opt.h.info, 'sty', 'edit', 'uni', 'norm', ...
  'pos', [.35 .35 .30 .1], 'str', num2str(opt.ylim(2)), 'tag', 'ylimval', ...
  'call', @cb_ylim);
uicontrol(opt.h.info, 'sty', 'push', 'uni', 'norm', ...
  'pos', [.70 .35 .25 .1], 'str', '-', ...
  'call', @cb_yd);

uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.05 .2 .4 .1], 'str', '75uV', ...
  'val', opt.grid75, 'call', @cb_grid75);

uicontrol(opt.h.info, 'sty', 'toggle', 'uni', 'norm', ...
  'pos', [.55 .2 .4 .1], 'str', '1s', ...
  'val', opt.grid1s, 'call', @cb_grid1s);
%-----------------%  
%-------------------------------------%

%-------------------------------------%
%-Menu bar
set(opt.h.main, 'Menubar', 'none')
m_file = uimenu(opt.h.main, 'label', 'File');
uimenu(m_file, 'label', 'Load MFF', 'call', @cb_loadmff);

m_chan = uimenu(opt.h.main, 'label', 'Channel Selection');
for i = 1:numel(opt.changrp)
  uimenu(m_chan, 'label', opt.changrp(i).chantype, 'call', @cb_selchan);
end

m_filt = uimenu(opt.h.main, 'label', 'Filter');
for i = 1:numel(opt.changrp)
  uimenu(m_filt, 'label', opt.changrp(i).chantype, 'call', @cb_filt);
end

m_ref = uimenu(opt.h.main, 'label', 'Reference');
for i = 1:numel(opt.changrp)
  uimenu(m_ref, 'label', opt.changrp(i).chantype, 'call', @cb_ref);
end

m_score = uimenu(opt.h.main, 'label', 'Sleep Score');
uimenu(m_score, 'label', 'New Score', 'call', @cb_newrater)
uimenu(m_score, 'label', 'Load Score', 'call', @cb_loadscore)
uimenu(m_score, 'label', 'Import Score from FASST', 'call', @cb_importscore)
uimenu(m_score, 'label', 'Rater', 'Sep', 'on', 'tag', 'uimenu_rater', 'enable', 'off')
uimenu(m_score, 'label', 'New Rater', 'call', @cb_newrater)
%-------------------------------------%

%-------------------------------------%
%-read the data if present in cfg
setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)

if isfield(cfg, 'dataset') 
  
  if ~isfield(cfg, 'hdr')
    cfg = mff_header(cfg, dirname);
    setappdata(0, 'cfg', cfg)
  end

  opt.beginrec = cfg.beginrec; %TODO: doc (or better handling)
  setappdata(0, 'opt', opt)  
  
  sleepscoring_init()
  cb_readplotdata()
  
end
%-------------------------------------%
%---------------------------------------------------------%

%---------------------------------------------------------%
%-CALLBACKS
%---------------------------------------------------------%

%-------------------------------------%
%-callback: load dataset
function cb_loadmff(h0, eventdata)

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

dirname = uigetdir;
if exist(dirname, 'dir') % TODO: what if pressed cancel?
  cfg.dataset = dirname;
  cfg = mff_header(cfg, dirname);
  opt.beginrec = cfg.beginrec;
end

setappdata(0, 'cfg', cfg)
setappdata(0, 'opt', opt)
sleepscoring_init()
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-add hdr and rec time
function cfg = mff_header(cfg, dirname)
cfg.hdr = ft_read_header(dirname);
cfg.fsample = cfg.hdr.Fs;
cfg.beginrec = datenum(cfg.hdr.orig.xml.info.recordTime([1:10 12:19]), 'yyyy-mm-ddHH:MM:SS');
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_selchan(h0, eventdata)

chantype = get(h0, 'label');

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

%-------%
%-don't show labels belonging to another chantype
nolabel = arrayfun(@(x) x.chan, opt.changrp(~changrp), 'uni', 0);
nolabel = [nolabel{:}];
[~, ilabel] = setdiff(cfg.label, nolabel);
label = cfg.label(sort(ilabel));
%-------%

[~, chanindx] = intersect(label, opt.changrp(changrp).chan);
chanindx = select_channel_list(label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).chan = label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: select channels
function cb_ref(h0, eventdata)

chantype = get(h0, 'label');

cfg = getappdata(0, 'cfg');
opt = getappdata(0, 'opt');

changrp = strcmp(chantype, {opt.changrp.chantype});

[~, chanindx] = intersect(cfg.label, opt.changrp(changrp).ref);
chanindx = select_channel_list(cfg.label, sort(chanindx)); % fieldtrip/private function
opt.changrp(changrp).ref = cfg.label(chanindx)';

setappdata(0, 'opt', opt);
cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: filter information
function cb_filt(h0, eventdata)

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
%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_loadscore(h0, eventdata)

%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_importscore(h0, eventdata)
%TODO: indicate that this will overwrite current score
%TODO: check that the length is consistent

[filename, pathname] = uigetfile('*.mat', 'Select FASST file');
warning off % class to struct warning
load([pathname filename], 'D')
warning on

cfg = getappdata(0, 'cfg');
if isfield(D.other, 'CRC') && isfield(D.other.CRC, 'score')
  cfg.score = D.other.CRC.score;

  cfg.rater = 1;
  setappdata(0, 'cfg', cfg)
  update_rater()
end
%-------------------------------------%

%-------------------------------------%
%-callback: load sleep score
function cb_newrater(h0, eventdata)

%-----------------%
cfg = getappdata(0, 'cfg');

if strcmp(get(h0, 'label'), 'New Score')
  ConfirmDel = questdlg('Are you sure that you want to delete the current scoring?', ...
    'Replace Score', ...
    'Yes', 'No', 'Yes');
  if strcmp(ConfirmDel, 'No'); return; end
  
  cfg.score = [];
end

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

sleepscoring_init()
update_rater()
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-callback: go back
function cb_bb(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = opt.epoch - 1;
setappdata(0, 'opt', opt);

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: go forward
function cb_ff(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = opt.epoch + 1;
setappdata(0, 'opt', opt);

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: change epoch
function cb_epoch(h0, eventdata)

opt = getappdata(0, 'opt');
opt.epoch = str2double(get(h0, 'str'));
setappdata(0, 'opt', opt)

cb_readplotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: smaller scale
function cb_yu(h0, eventdata)

opt = getappdata(0, 'opt');
opt.ylim = opt.ylim / 1.1;
setappdata(0, 'opt', opt);

cb_ylim()
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_yd(h0, eventdata)

opt = getappdata(0, 'opt');
opt.ylim = opt.ylim * 1.1;
setappdata(0, 'opt', opt);

cb_ylim()
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: adjust scale
function cb_ylim(h0, eventdata)

opt = getappdata(0, 'opt');

if nargin > 0
  
  opt.ylim = [-1 1] * str2double(get(h0, 'str'));
  setappdata(0, 'opt', opt);
  cb_plotdata()
  
else
  set(findobj('tag', 'ylimval'), 'str', num2str(opt.ylim(2)));
  
end
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid75(h0, eventdata)

opt = getappdata(0, 'opt');
opt.grid75 = ~opt.grid75;
setappdata(0, 'opt', opt);

set(findobj('str', '75uV'), 'val', opt.grid75)
cb_plotdata()
%-------------------------------------%

%-------------------------------------%
%-callback: larger scale
function cb_grid1s(h0, eventdata)

opt = getappdata(0, 'opt');
opt.grid1s = ~opt.grid1s;
setappdata(0, 'opt', opt);

set(findobj('str', '1s'), 'val', opt.grid1s)
cb_plotdata()
%-------------------------------------%
%---------------------------------------------------------%