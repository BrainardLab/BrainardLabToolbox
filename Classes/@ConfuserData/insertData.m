function cdObj = insertData(cdObj, trialIndex, staircaseIndex, studyColor, testColor)
% cdObj = insertData(cdObj, trialIndex, staircaseIndex, studyColor, testColor)
%
% Description:
% Inserts study and test color values into the ConfuserData object at the
% specified trial and staircase indices.
%
% Inputs:
% cdObj (ConfuserData) - The ConfuserData object to operate on.
% trialIndex (integer) - The trial number of color data to insert.
% staircaseIndex (integer) - The staircase number of the color data to insert.
% studyColor (1x3 double) - RGB value of the study object. (r,g,b)[0,1]
% testColor (1x3 double) - RGB value of the test object. (r,g,b)[0,1]
%
% Output:
% cdObj (ConfuserData) - Updated ConfuserData object.

if nargin ~= 5
	error('Usage: cdObj = insertData(cdObj, trialIndex, staircaseIndex, studyColor, testColor)');
end

% Make sure that the RGB values are 1x3 vectors.
if ~isvector(studyColor) || numel(studyColor) ~= 3
	error('studyColor must be a 1x3 vector');
end
if ~isvector(testColor) || numel(testColor) ~= 3
	error('testColor must be a 1x3 vector');
end

% Make sure that the indices are within the valid range.
if trialIndex < 1 || trialIndex > cdObj.numTrials
	error('trialIndex must be in the range [1,%d]', cdObj.numTrials);
end
if staircaseIndex < 1 || staircaseIndex > cdObj.numStaircases
	error('staircaseIndex must be in the range [1,%d]', cdObj.numStaircases);
end

cdObj.data{trialIndex, staircaseIndex} = [studyColor ; testColor];
