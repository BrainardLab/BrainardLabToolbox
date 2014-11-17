function CheckScanData(dataFileOrdataFolder)

if nargin ~= 1
	error('Usage: CheckScanData(dataFileOrdataFolder)');
end

% Make a bogus TimeTracker object because Matlab gets pissed off if a class
% hasn't been instantiated at least once before calling a member function.
TimeTracker({'a'}, 1);

% If we're given a directory, get a list of all data files inside and check
% each one.
if isdir(dataFileOrdataFolder)
    dirContents = dir(sprintf('%s/*.mat', dataFileOrdataFolder));
    
    for i = 1:length(dirContents)
        fname = which(dirContents(i).name);
        fprintf('Checking file %s\n', fname);
        CheckData(fname);
    end
else
    CheckData(which(dataFileOrdataFolder))
end


function CheckData(dataFile)
% Make sure the data file exists.
if ~exist(dataFile, 'file');
	error('Cannot find data file.');
end

load(which(dataFile));

% Make sure the file is valid.  A valid file contains the TimeTracker
% object 'timeResponseData'.
if exist('timeResponseData', 'var') == 0
    fprintf('*** %s is an invalid file ***\n', dataFile);
    return;
end

% Find irregular trs.
tr = getData(timeResponseData, 'tr');
dtr = diff(tr);
slop = 0.5;
threshold = mean(dtr) + slop;
crapTRs = find(dtr > threshold | dtr < (threshold-2*slop)) + 1;

if isempty(crapTRs)
	disp('File is normal');
else
	fprintf('*** %d TR errors ***\n', length(crapTRs));
	for i = 1:length(crapTRs)
		fprintf('TR #%d, time: %f, diff: %f\n', crapTRs(i), tr(crapTRs(i)) - tr(1), ...
			dtr(crapTRs(i)-1));
	end
end
