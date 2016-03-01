function validateValueForParam(obj, paramName, paramValue, backTrace)
    if (isKey(obj.validValues, paramName))
        % We have valid range for paramName
        % check if we are within it
        if (~ismember(paramValue, obj.validValues(paramName)))
            error('%s: Received invalid value (''%s'') for param ''%s''.', backTrace, paramValue, paramName);
        end
    end
    
end
