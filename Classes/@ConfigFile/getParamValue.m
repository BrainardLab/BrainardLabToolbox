function value = getParamValue(object, paramName, stringForm)
% value = getParamValue(paramName, [stringForm])
% 
% Description:
% Retrieves the value of the parameter specified by 'paramName'.
%
% Required Inputs:
% paramName (string) - Name of the parameter to access.
%
% Optional Inputs
% stringForm (boolean) - If true, then the value is returned in a string format.  By
%	default, it is false.

if nargin < 2 || nargin > 3
	error('Usage: getParamValue(paramName, [stringForm])');
end

if nargin == 2
	stringForm = false;
end

value = NaN;

for i = 1:length(object.Params)
	if strcmp(paramName, object.Params(i).paramName)
		if stringForm
			value = object.Params(i).paramValRaw;
		else
			value = object.Params(i).paramVal;
		end
		
		break;
	end
end

% Check to see if we found the parameter.
if isnan(value)
	error('%s not a valid parameter name', paramName);
end
