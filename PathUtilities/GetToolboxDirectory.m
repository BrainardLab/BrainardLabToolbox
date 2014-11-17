function toolboxDir = GetToolboxDirectory(toolboxName, suppressWarning)
% toolboxDir = GetToolboxDirectory(toolboxName, [suppressWarning])
%
% Description:
% Returns the root directory of the requested toolbox.
%
% Input:
% toolboxName (string) - Name of the toolbox.
%
% Optional Input:
% suppressWarning (logical) - If true, this function doesn't print out a
%    warning message if the toolbox wasn't found.  Defaults to false.
%
% Output:
% toolboxDir (string) - Root directory of the toolbox or empty if the
%	toolbox isn't found.
%

if nargin < 1 || nargin > 2
	error('toolboxDir = GetToolboxDirectory(toolboxName, [suppressWarning])');
end

if nargin == 1
	suppressWarning = false;
end

p = path;
toolboxDir = [];

% Parse the path.
x = textscan(p, '%s', 'Delimiter', ':');
x = x{1};

% Look at each entry to find the toolbox.
for i = 1:length(x)
	[p, f] = fileparts(x{i});
	
	if ~isempty(strmatch(f, toolboxName, 'exact'))
		toolboxDir = sprintf('%s/%s', p, f);
	end
end

if isempty(toolboxDir) && ~suppressWarning
	fprintf('*** Toolbox "%s" not found on the path.', toolboxName);
end
