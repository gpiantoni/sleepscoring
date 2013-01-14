function y = valid_label(x)

import io.edfplus.is_valid_label;

if ~iscell(x),
    x = {x};
end

isValid = is_valid_label(x);

if any(~isValid),
    x(~isValid) = cellfun(@(arg) force_valid(arg), x(~isValid), ...
        'UniformOutput', false);
end

y = x;


end


function y = force_valid(x)

expr = '(?<type>.+)[.]*\s+(?<spec>\w+)$';

type = '';
spec = '';

match = regexp(x, expr, 'names');
if iscell(match), match = match{1}; end
if ~isempty(match)
    type = match.type;
    spec = match.spec;
else
    expr = '(?<type>.+)[.]*-(?<spec>\w+)$';
    match = regexp(x, expr, 'names');
    if iscell(match), match = match{1}; end
    if ~isempty(match)
        type = match.type;
        spec = match.spec;
    end
end

if isempty(type),
    type = x;
end

if ~isempty(regexpi(type, '^resp', 'once')),
    type = 'Resp';
elseif ~isempty(regexpi(type, '^temp', 'once')),
    type = 'Temp';
elseif ~isempty(regexpi(type, '^emg', 'once')),
    type = 'EMG';
elseif ~isempty(regexpi(type, '^pos', 'once')),
    type = 'Pos';
elseif strcmpi(x, 'body position'),
    type = 'Pos';
    spec = 'Body';
else
    type = 'Unknown';
    spec = '';
end

if isempty(spec),
    y = type;
else
    y = [type ' ' spec];
end


end