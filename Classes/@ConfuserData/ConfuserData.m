function cdObj = ConfuserData(numTrials, numStaircases)
% cdObj = ConfuserData(numTrials, numStaircases)
%
% Description:
% Creates a data structure to hold confuser data for the color memory
% experiments.
%
% Inputs:
% numTrials (integer) - Number of trials.
% numStaircases (integer) - Number of staircases.
%
% Output:
% cdObj (ConfuserData) - The newly created ConfuserData object.

if nargin ~= 2
	error('cdObj = ConfuserData(numTrials, numStaircases)');
end

cdObj.data = cell(numTrials, numStaircases);
cdObj.numTrials = numTrials;
cdObj.numStaircases = numStaircases;

cdObj = class(cdObj, 'ConfuserData');
