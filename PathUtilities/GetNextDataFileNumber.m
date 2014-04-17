function nextNumber = GetNextDataFileNumber(dataFolder, dataFileSuffix)
% GetNextDataFileNumber - Returns the next data file number for a data folder.
%
% Syntax:
% nextNumber = GetNextDataFileNumber(dataFolder)
% nextNumber = GetNextDataFileNumber(dataFolder, dataFileSuffix)
%
% Description:
% For some experiments, data files are saved with a number appended to the
% end, e.g. datafile1.mat, datafile2.mat, etc.  This function simply counts
% up the number of data files in the specified folder and returns the count
% plus 1.  If there is no data in the folder, 1 is returned.
%
% Input:
% dataFolder (string) - The name of the data folder.
% dataFileSuffix (string) - File extension for data files.  Default: .mat
%
% Output:
% nextNumber (scalar) - The next data file number.

if nargin < 1 || nargin > 2
	error(help('GetNextDataFileNumber'));
end

if ~exist(dataFolder, 'dir')
	error('Cannot find folder %s', dataFolder);
end

if ~ischar(dataFolder)
	error('"dataFolder" must be a string.');
end

% Make sure there's a '/' at the end of the data folder.
if dataFolder(end) ~= '/'
	dataFolder(end+1) = '/';
end

% Set the default file suffix if not specified.
if nargin == 1
	dataFileSuffix = '.mat';
end

% Get the number of data files in the directory.
d = dir(sprintf('%s*%s', dataFolder, dataFileSuffix));
nextNumber = length(d) + 1;
