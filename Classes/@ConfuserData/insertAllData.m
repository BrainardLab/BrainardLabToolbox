function cdObj = insertAllData(cdObj, dataMatrix)
% cdObj = insertAllData(cdObj, dataMatrix)
%
% Description:
% Sets all the data elements at once for a ConfuserData object.
%
% Inputs:
% cdObj (ConfuserData) - Confuser data object to operate on.
% dataMatrix (numTrials x numStaircases x 2 x 3 double) - Matrix that contains
%	the values for every element of the ConfuserData object.
%
% Output:
% cdObj (ConfuserData) - Updated ConfuserData object.

if nargin ~= 2
	error('Usage: cdObj = insertAllData(cdObj, dataMatrix)');
end

% Make sure that 'dataMatrix' is the correct size.
if ~all(size(dataMatrix) == [cdObj.numTrials cdObj.numStaircases 2 3])
	error('dataMatrix must have the following dimensions: [%d %d 2 3]', ...
		cdObj.numTrials, cdObj.numStaircases);
end

for i = 1:cdObj.numTrials
	for j = 1:cdObj.numStaircases
		s = squeeze(dataMatrix(i,j,1,:))';
		t = squeeze(dataMatrix(i,j,2,:))';
		cdObj.data{i,j} = [s ; t];
	end
end
