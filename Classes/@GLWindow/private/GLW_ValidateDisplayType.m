function [validatedDisplayType, displayTypeID] = GLW_ValidateDisplayType(desiredDisplayType)
% GLW_ValidateDisplayType - Validates a display type.
%
% Syntax:
% [validatedDisplayType, displayTypeID] = GLW_ValidateDisplayType(desiredDisplayType)
%
% Description:
% Validates a display type based on the types known by GLWindow.
%
% Input:
% desiredDisplayType (string|[]) - The desired display type.
%
% Output:
% validatedDisplayType (string) - If the display type input is valid, this
%     value will be 'desiredDisplayType' but formatted as a proper noun, i.e.
%     'Normal, 'Bits++'.  You can see the list of valid display types by
%     running: fieldnames(GLWindow.DisplayTypes)
% diplayTypeID (integer) - This is the numerical ID associated with the
%	  valided display type.

if nargin ~= 1
	error('Usage: validatedDisplayType = GLW_ValidateDisplayType(desiredDisplayType)');
end

% Make sure the input is valid.
if isempty(desiredDisplayType) % Default
	desiredDisplayType = 'Normal';
elseif ~ischar(desiredDisplayType)
	error('"desiredDisplayType" must be a string.');
end

% Get a list of available display types and see if the one asked for is in
% that list.
availableDisplayTypes = fieldnames(GLWindow.DisplayTypes);
i = strcmpi(desiredDisplayType, availableDisplayTypes);

% Check to see if the input is in the GLWindow list of legit display types.
if ~any(i)
	error('"%s" is not a valid display type.', desiredDisplayType);
end

% Make the desired display type lower case and return it.
validatedDisplayType = availableDisplayTypes{i};
displayTypeID = GLWindow.DisplayTypes.(availableDisplayTypes{i});
