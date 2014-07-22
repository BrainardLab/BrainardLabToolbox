function dataMatrix = getAllData(cdObj)
% dataMatrix = getAllData(cdObj)
%
% Description:
% Gets all the data contained in a ConfuserData object and returns it in
% matrix format.
%
% Input:
% cdObj (ConfuserData) - ConfuserData object to get data from.
%
% Output:
% dataMatrix (numTrials x numStaircases x 2 x 3 double) - Matrix with all
%	the data from the ConfuserData object.

if nargin ~= 1
	error('Usage: dataMatrix = getAllData(cdObj)');
end

% Allocate the memory to hold all the data.
dataMatrix = zeros(cdObj.numTrials, cdObj.numStaircases, 2, 3);

for i = 1:cdObj.numTrials
	for j = 1:cdObj.numStaircases
		dataElement = cdObj.data{i,j};
		dataMatrix(i,j,1,:) = dataElement(1,:);
		dataMatrix(i,j,2,:) = dataElement(2,:);
	end
end
