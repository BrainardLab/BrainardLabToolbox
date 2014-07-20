function paramsList = listParams(object)
% paramsList = listParams
%
% Description:
% Lists the parameter names in the config file.
%
% Output:
% paramsList - Cell array of strings containing all parameter names stored 
%              in the ConfigFile object.

if nargin ~= 1
	error('Usage: paramsList = listParams');
end

pl = {object.Params.paramName};
paramsList = sort(pl);
