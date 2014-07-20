function [studyColor, testColor] = getData(cdObj, trialIndex, staircaseIndex)
% [studyColor, testColor] = getData(cdObj, trialIndex, staircaseIndex)
%
% Description:
% Gets the study and test color from a ConfuserData object indexed by the
% trial number and staircase number.
%
% Inputs:
% cdObj (ConfuserData) - The ConfuserData object to operate on.
% trialIndex (integer) - The trial number of color data to extract.
% staircaseIndex (integer) - The staircase number of the color data to extract.
%
% Outputs:
% studyColor (1x3 vector) - The RGB study color value.
% testColor (1x3 vector) - The RGB test color value.

if nargin ~= 3
	error('Usage: [studyColor, testColor] = getData(cdObj, trialIndex, staircaseIndex)');
end

% Make sure that the indices are within the valid range.
if trialIndex < 1 || trialIndex > cdObj.numTrials
	error('trialIndex must be in the range [1,%d]', cdObj.numTrials);
end
if staircaseIndex < 1 || staircaseIndex > cdObj.numStaircases
	error('staircaseIndex must be in the range [1,%d]', cdObj.numStaircases);
end

data = cdObj.data{trialIndex, staircaseIndex};
if ~isempty(data)
	studyColor = data(1,:);
	testColor = data(2,:);
else
	studyColor = [];
	testColor = [];
end
