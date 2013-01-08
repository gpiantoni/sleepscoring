function info = find_dataset(info)
%FIND_DATASET find best-matching dataset

if ~exist(info.dataset, 'file')
  
  fprintf('could not find %s. Trying possible files:\n', info.dataset)

  %-----------------%
  %-get information about the directories
  [dir{1} name{1}] = fileparts(info.dataset);
  [dir{2} name{2}] = fileparts(info.infofile);
  ext = {'' '.mff' '.mat'}; % possible extension of the recordings
  %-----------------%
  
  %-----------------%
  %-loop over possible names
  found = false;
  
  for i1 = 1:numel(dir)
    for i2 = 1:numel(name)
      for i3 = 1:numel(ext)
        
        dataset = fullfile(dir{i1}, [name{i2} ext{i3}]);
        
        if exist(dataset, 'file') && ...
            exist([dataset filesep 'signal1.bin'], 'file') % contains EEG data
          
          found = dataset;
          fprintf('       FOUND: %s\n', dataset);
          
        else
          fprintf('   not found: %s\n', dataset);
          
        end
        
      end
    end
  end
  %-----------------%
  
  %-----------------%
  %-prepare output
  if found
    info.dataset = found;
    
  else
    error('could not find corresponding dataset')
    
  end
  %-----------------%
  
end