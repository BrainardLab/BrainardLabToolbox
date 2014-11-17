function windowProperty = getWindowProperty(glwObj, property)
% windowProperty = getWindowProperty(glwObj, property)
% 
% Description:
% Returns a window property value.
%
% Inputs:
% glwObj (GLWindow) - The GLWindow whose property you want.
% property (string) - The name of the property.
%
% Output:
% windowProperty - The current property value.

if nargin ~= 2
	error('Usage: windowProperty = getWindowProperty(glwObj, property)');
end

windowProperty = [];

switch lower(property)
	case 'gamma'
		windowProperty = glwObj.gamma;
    case 'windowposition'
        windowProperty = glwObj.windowposition;
	otherwise
		error('GLWindow/getWindowProperty: Property "%s" not found.', property);
end
