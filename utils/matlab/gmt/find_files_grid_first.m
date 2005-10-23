function [flist] = find_files_grid_first(fpat)

% Function [flist] = find_files_grid_first(fpat)
%
% INPUTS
%   fpat     either a string containing a file pattern
%              (eg. 'state.*.nc) or a cell array of file patterns
%
% OUTPUTS
%   flist    cell array of file names
%
%
%  Ed Hill
%  $Id$

files = {};
if ischar(fpat)
  tmp = fpat;
  fpat = {};
  fpat = { tmp };
end
for ip = 1:length(fpat)
  d = dir(fpat{ip});
  for i = 1:length(d)
    files{end+1} = d(i).name;
  end
end
fall = sort(unique(files));
%  Order all the files with any grid files first and the rest
%  alphabetically
m = regexp(fall, 'grid.+', 'match');
grid_files = {};
data_files = {};
fordered = {};
for i = 1:length(m)
  if not(isempty(m{i}))
    fordered{end+1} = fall{i};
  end
end
for i = 1:length(m)
  if isempty(m{i})
    fordered{end+1} = fall{i};
  end
end
flist = fordered;

