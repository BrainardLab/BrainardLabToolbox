function GLW_ValidateStructFields(structObj, validFields)
% GLW_ValidateStructFields(structObj, validFields)
%
% Description:
% Verifies that a struct object only contains certain fields.  Errors if
% not the case.
%
% Input:
% structObj (struct) - Struct object to inspect.
% validFields (cell array) - Cell array of strings, i.e. fieldnames, that
%	'structObj' should contain.

if nargin ~= 2
	error('Usage: GLW_ValidateStructFields(structObj, validFields)');
end

% Check the input.
if ~isstruct(structObj)
	error('"structObj" must be a struct.');
end
if ~iscell(validFields)
	error('"validFields must be a cell array.');
end

% Get the field names attached to the struct.
structFields = fieldnames(structObj);

% Make sure we have the right number of fields.  The number of these 2
% things should always be the same.
if length(structFields) ~= length(validFields)
	error('Invalid number of fields (%d) in the struct.', length(structFields));
end

% Check for each fieldname in the struct.  All names must match.
for i = 1:length(validFields)
	% Make sure we have the desired field.
	if ~any(strcmp(validFields{i}, structFields))
		error('Cannot find the "%s" field in the struct.', validFields{i});
	end
end
