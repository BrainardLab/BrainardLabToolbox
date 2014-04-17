function obj = loadProperty(obj, propertyName, propertyValue)
% obj = loadProperty(obj, propertyName, propertyValue)
%
% Description: Load the passed property with the passed value
%
% Required inputs:
%   obj             - staircase object
%   propertyName    - name of the staircase property to be loaded
%   propertyValue   - new value of the property to be loaded
%
% Outputs:
%  obj              - the updated staircase object
%
% 3/27/2013 npc Wrote it
%
    eval(sprintf('obj.%s = propertyValue;', propertyName));
end
