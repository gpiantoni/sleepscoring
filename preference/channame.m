function label = channame(label)
%CHANNAME with this function you can rename channels, to give more
% meaningful names. Input is the labels read from the header file and the
% output is the labels used in the analysis. The final labels will be
% stored in CFG.

% Here one example of renaming one channel

%-----------------%
%-scalp EEG
label{strcmp(label,  'E41')} = 'F3';
label{strcmp(label, 'E214')} = 'F4';
label{strcmp(label,  'E59')} = 'C3';
label{strcmp(label, 'E183')} = 'C4';
label{strcmp(label, 'E124')} = 'O3';
label{strcmp(label, 'E149')} = 'O4';

label{strcmp(label,  'E94')} = 'LM';
label{strcmp(label, 'E190')} = 'RM';
%-----------------%

%-----------------%
%-EOG
label{strcmp(label, 'E234')} = 'REOG';
label{strcmp(label, 'E244')} = 'LEOG';
%-----------------%

%-----------------%
%-EMG
label{strcmp(label, 'E165')} = 'EMG';
%-----------------%
