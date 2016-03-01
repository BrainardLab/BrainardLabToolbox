function validateValueForParam(obj, paramName, paramValue, backTrace)
    if (isKey(obj.validParamValues, paramName))
        % We have valid range for paramName
        % check if we are within it
        if (~ismember(paramValue, obj.validParamValues(paramName)))
            error('%s: Received invalid value (''%s'') for param ''%s''.', backTrace, paramValue, paramName);
        end
    end
    
end
