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
