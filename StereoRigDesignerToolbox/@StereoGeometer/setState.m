% Helper method for updating class properties
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function setState(obj, s)
    
    % update copy of input struct
    % this is used purely for the gui callbacks
    % to save their updated property values
    obj.stereoRigState = s;
    
    % set the values of the primary properties
    propertyNames = fieldnames(s);
    for k = 1:numel(propertyNames)
        obj.(propertyNames{k}) = s.(propertyNames{k});
    end
    
    obj.computeDependentProperties();
    
end
