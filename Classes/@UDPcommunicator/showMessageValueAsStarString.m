function showMessageValueAsStarString(obj, messageCount, direction, msgLabel, msgValueType, msgValue, maxValue, maxStars)

    if (strcmp(lower(msgValueType), 'string'))
        starsNum = length(msgValue)/maxValue*maxStars;  % length of string
    elseif (strcmp(lower(msgValueType), 'boolean'))
        if (msgValue)
            starsNum = maxStars-5;
        else
            starsNum = 5;
        end
    elseif (strcmp(lower(msgValueType), 'numeric'))
        starsNum = msgValue / maxValue * maxStars;
    end
    
    
    msg = '';
    for k = 1:starsNum
        msg(k) = '*';
    end
    
    if (strcmp(lower(msgValueType), 'string'))
        fprintf('\n [%d]: %10s %-20s (%10s with value: ''%s''): %41s', messageCount, direction, msgLabel, msgValueType, msgValue, msg);
    elseif (strcmp(lower(msgValueType), 'boolean'))
        if (msgValue)
            fprintf('\n [%d]: %10s %-20s (%10s with value: TRUE ): %41s', messageCount, direction, msgLabel, msgValueType, msg);
        else
            fprintf('\n [%d]: %10s %-20s (%10s with value: FALSE): %41s', messageCount, direction, msgLabel, msgValueType, msg);
        end
    elseif (strcmp(lower(msgValueType), 'numeric'))
        fprintf('\n [%d]: %10s %-20s (%10s with value %3.3f): %41s', messageCount, direction, msgLabel, msgValueType, msgValue, msg);
    end
    
end

