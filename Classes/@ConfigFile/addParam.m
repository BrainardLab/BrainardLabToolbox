function object = addParam(object, paramName, paramType, paramVal, paramDescription)
% function object = addParam(object, paramName, paramType, paramVal, [paramDescription])
%
% Description:
% Adds a parameter to the ConfigFile 'object'.
%
% Input:
% object (ConfigFile) - ConfigFile object which will be augmented.
% paramName (char) - Name of the parameter to be added.
% paramType (char) - Type of parameter to be added.  Can be any of the following values:
%	1. 'd' - double type
%	2. 's' - string type
%	3. 'b' - boolean type
% paramVal (char) - Value the parameter should hold.
% [paramDescription] (char) - Description of the parameter.  Defaults to
%	an empty string.

if nargin < 4 || nargin > 5
	error('Usage: object = addParam(object, paramName, paramType, paramVal, [paramDescription])');
end

if ~exist('paramDescription', 'var') || isempty(paramDescription)
	paramDescription = '';
end

i = length(object.Params) + 1;

object.Params(i).paramName = paramName;
object.Params(i).paramType = paramType;
object.Params(i).paramValRaw = paramVal;
object.Params(i).paramDescription = paramDescription;

% Convert the parameter value into its specified type.  When params
% are read in from the file, they are in string format.
switch paramType
	case 'd' % double
		[object.Params(i).paramVal, ok] = str2num(paramVal); %#ok<ST2NM>

		if ok == 0
			error('Could not convert %s to a double value', paramVal);
		end
	case 's' % string
		object.Params(i).paramVal = paramVal;
	case 'b' % boolean
		if any(strcmp(paramVal, {'true', '1'}))
			object.Params(i).paramVal = true;
		elseif any(strcmp(paramVal, {'false', '0'}))
			object.Params(i).paramVal = false;
		else
			error('Invalid boolean value %s', paramVal);
		end
	otherwise
		error('Invalid parameter type %s', paramType);
end
