 function description = getParamDescription(CFObj, paramName)
% description = CFObj.getParamDescription(paramName)
%
% Description:
% Returns the description for the parameter specified by 'paramName'.

if nargin ~= 2
	error('Usage: description = CFObj.getParamDescription(paramName)');
end

description = NaN;

for i = 1:length(CFObj.Params)
	if any(strcmp(paramName, CFObj.Params(i).paramName))
		description = CFObj.Params(i).paramDescription;
		break;
	end
end

% Check to see if we found the parameter.
if isnan(description)
	error('%s not a valid parameter name', paramName);
end
