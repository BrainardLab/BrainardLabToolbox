function newObject = loadObject(newObject, oldObject)
% newObject = loadObject(oldObject)
%
% Description: Update a new staircase object by copying an old staircase object
%
% Required inputs:
%   newObject   - the new object (dummy values in it)
%   oldObject   - the staircase object to be copied
% 
% Outputs:
%   newObject   - the updated new staircase object
%
% 3/27/2013 npc Wrote it
%
    % get list of all property names in the old object
    propertiesStruct = struct(oldObject);
    propertyNamesList = fieldnames(propertiesStruct);

    % set the values of the newObject properties to those of the oldObject
    for propertyIndex = 1:length(propertyNamesList)
        propertyName  = propertyNamesList{propertyIndex};
        propertyValue = eval(sprintf('propertiesStruct.%s',propertyName)); 
        newObject     = loadProperty(newObject, propertyName, propertyValue);
    end
end
