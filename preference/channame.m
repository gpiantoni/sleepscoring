function label = channame(label)
%CHANNAME with this function you can rename channels, to give more
% meaningful names. Input is the labels read from the header file and the
% output is the labels used in the analysis. The final labels will be
% stored in CFG.

% Here one example of renaming one channel
label{strcmp(label, 'E244')} = 'LEOG';