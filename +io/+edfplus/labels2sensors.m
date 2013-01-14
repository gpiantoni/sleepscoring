function sensorArray = labels2sensors(labels)
% LABELS2SENSORS - Convert sensor labels to sensors object
%
% Only two types of sensors will be considered: EEG and physiology
% (anything that is not EEG)
%
% See also: edfplus

import io.edfplus.signal_types;
import misc.strtrim;
import sensors.eeg;
import sensors.meg;
import sensors.physiology;
import sensors.mixed;

edfTypes = signal_types;


%% Extract sensor type and specification
regex = '^(?<type>\w+)[.]*\s+(?<spec>\w+)';

type = cell(size(labels));
spec = cell(size(labels));
newLabels = cell(size(labels));

for i = 1:numel(labels)
    
    newLabels{i} = strtrim(labels{i});
    match = regexp(newLabels{i}, regex, 'names');
    
    if isempty(match) || ~ismember(match.type, edfTypes),
        type{i} = 'Unknown';
        spec{i} = regexprep(newLabels{i}, '[^\w]+', '-');
    else
        type{i} = match.type;
        spec{i} = match.spec;
    end
    
    tmp = sprintf('%s %s', type{i}, spec{i});
    
    %% Enforce unique labels
    count = 0;
    while ismember(tmp, newLabels(1:i-1)),
        count = count + 1;
        tmp = sprintf('%s %s %d', type{i}, spec{i}, count);
    end
    
    newLabels{i} = tmp;
    
end




%% Process EEG sensors
isEEG = cellfun(@(x) strcmp(x, 'EEG'), type);
eegSensors = eeg.guess_from_labels(newLabels(isEEG));

if any(~isEEG),
    
    if find(isEEG(:), 1, 'last') > find(~isEEG(:), 1, 'first'),
        error('Something is wrong');
    end
    
    physSensors = physiology('Label', newLabels(~isEEG));
    sensorArray = mixed(eegSensors, physSensors);
else
    sensorArray = eegSensors;
end

end