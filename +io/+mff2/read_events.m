function evArray = read_events(filename, fs, beginTime)

import mperl.split;
import misc.isinteger;
import io.mff2.read_header;
import io.mff2.read_data;

if nargin < 3 || isempty(beginTime),
    hdr = read_header(filename);
    beginTime = hdr.beginTime;
end
beginTime = parse_begin_time(beginTime);

if nargin < 2 || isempty(fs),
   error('The sampling rate needs to be provided!');
end

% Important: keep the '/' at the end. For some reason it is required 
% under Linux (otherwise Perl's find() does not realize that the .mff
% file is a directory).
res = perl('+io/+mff2/private/parse_events.pl', [filename '/']);
res = split(char(10), res);

nbEvents = numel(res)/3;

if ~isinteger(nbEvents),
    error('Something went wrong');
end

evArray = repmat(pset.event.event, nbEvents, 1);
evCount = 0;
for evItr = 1:nbEvents
    
    offset      = (evItr-1)*3;
    evTime      = res{offset+1};
    duration    = res{offset+2};
    code        = res{offset+3};
    if isempty(beginTime),
        continue;
    end
    
    evTime   =  parse_begin_time(evTime);
    evSample = floor((evTime - beginTime)*24*60*60*fs)+1;
    
    % Ignore events before the recording started
    if evSample > 0,
        evCount = evCount + 1;
        % We set only public props so this is faster than using method
        % set(), which is generally preferred. As .mff files can
        % contain thousands of events, this can save some time.
        evArray(evCount).Sample      = evSample;
        evArray(evCount).Type        = code;
        evArray(evCount).Duration    = ...
            ceil(str2double(duration)./1000000000*fs);
    end
end

end