function SVNUpdateToolboxes
% SVNUpdateToolboxes
%
% Description:
% Looks in the standard toolboxes folder and runs "svn update" on all top
% level folders found.  Useful for updating all your SVN checked out
% toolboxes en masse.

try
	% The standard Brainard Lab toolbox folder.
	toolboxDir = '/Users/Shared/Matlab/Toolboxes';
	
	% Get a list of all folders in the toolbox folder.
	dirContents = dir(toolboxDir);
	
	% Filter out any folders that start with '.'.
	toolboxDirs = {};
	numToolboxes = 0;
	for i = 1:length(dirContents)
		if dirContents(i).isdir && isempty(regexp(dirContents(i).name, '^\.', 'once'))
			numToolboxes = numToolboxes + 1;
			toolboxDirs{numToolboxes} = sprintf('%s/%s', toolboxDir, dirContents(i).name); %#ok<AGROW>
		end
	end
	
	% Quit if there are no toolboxes to update.
	if numToolboxes == 0
		error('notoolboxes');
	end
	
	% Get the Subversion binary path.
	svn = sprintf('%ssvn', GetSubversionPath);
	
	% Run the 'svn update' command on all toolboxes.
	for i = 1:numToolboxes
		fprintf('- Updating %s...', toolboxDirs{i});

		[status, result] = system(sprintf('%s update %s', svn, toolboxDirs{i}));
% 		if status ~= 0
% 			fprintf('%s\n', result);
% 		else
% 			fprintf('Done\n');
% 		end
		
		fprintf('%s\n', result);
	end
catch e
	switch e.message
		case 'notoolboxes'
			beep;
			fprintf('\n* No toolboxes installed, doing nothing.\n');
			
		otherwise
			rethrow(e);
	end
end
