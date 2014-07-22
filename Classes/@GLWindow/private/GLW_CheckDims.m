function isOK = GLW_CheckDims(inputMatrix, sizeList)
% GLW_CheckDims - Checks matrix size vs a list of possible sizes.
%
% Syntax:
% isOK = GLW_CheckDims(inputMatrix, sizeList)
%
% Description:
% Checks to see if the input matrix has a size equal to any of the sizes
% listed in 'sizeList'.
%
% Input:
% inputMatrix - Basically, any Matlab object that returns something when
%   'size' is called on it.
% sizeList (1xN cell) - Cell array of size vectors.
%
% Output:
% isOK (logical) - True if the size of 'inputMatrix' matches
%   anything in the 'sizeList'.
%
% Example:
% A = rand(1, 3, 2);
% sizeList = {[1 2], [1 3 2], [4 8]};
% isOK = GLW_CheckDims(A, sizeList);
%
% -- isOK will evaluate to true.

% Make sure that 'sizeList' as passed as a cell array.
assert(iscell(sizeList), 'GLW_CheckDims:InvalidInput', ...
	'Input must be a cell array.');

inputSize = size(inputMatrix);
numSizes = length(sizeList);
isOK = false;

for i = 1:numSizes
	if isequal(inputSize, sizeList{i})
		isOK = true;
		break;
	end
end
