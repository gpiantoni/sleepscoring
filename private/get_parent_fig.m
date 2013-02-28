function h = get_parent_fig(h)
%GET_PARENT_FIG simple recursive function to find parent figure

while ~isempty(h) && ~strcmp('figure', get(h,'type'))
  h = get(h,'parent');
end