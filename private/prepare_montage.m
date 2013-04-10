function [mont] = prepare_montage(grpchan, label)
%PREPARE_MONTAGE prepare montage to sum electrodes together
% Use as:
%   [mont] = prepare_montage(chan, label)
% where chan is a struct with:
%   .name = 'name of group elec'
%   .elec = {'elec'}
% and label is data.label
% Mont can be used for ft_apply_montage(data, mont)

%-----------------%
%-prepare TRA
nnew = numel(grpchan);
nold = numel(label);

tra = zeros(nnew, nold);

for i = 1:nnew
  ism = ismember(label, grpchan(i).chan)';
  tra(i,:) = ism / numel(find(ism));
end
%-----------------%

%-----------------%
%-prepare MONT
mont.labelorg = label;
mont.labelnew = {grpchan.name}';
mont.tra = tra;
%-----------------%