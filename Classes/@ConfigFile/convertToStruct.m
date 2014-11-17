function cfStruct = convertToStruct(CFObj)
% cfStruct = convertToStruct(CFObj)
%
% Description:
% Converts all parameters contained in the ConfigFile object into a struct.
%
% Required Inputs:
% CFObj (ConfigFile) - The ConfigFile object to operate on.
%
% Output:
% cfStruct (struct) - Struct containing all ConfigFile items and their
%	associated data.

if nargin ~= 1
	error('Usage: cfStruct = convertToStruct(CFObj)');
end

for i = 1:length(CFObj.Params)
	paramName = CFObj.Params(i).paramName;
	paramVal = CFObj.Params(i).paramVal;
	
	cfStruct.(paramName) = paramVal;
end
