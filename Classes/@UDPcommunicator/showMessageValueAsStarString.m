function showMessageValueAsStarString(obj, direction, msgLabel, msgValueType, msgValue, maxValue, maxStars)

    if (strcmp(lower(msgValueType), 'string'))
        starsNum = length(msgValue)/maxValue*maxStars;  % length of string
    elseif (strcmp(lower(msgValueType), 'boolean'))
        if (msgValue)
            starsNum = maxStars-1
        else
            starsNum = 1;
        end
    elseif (strcmp(lower(msgValueType), 'numeric'))
        starsNum = msgValue / maxValue * maxStars;
    end
    
    
    msg = '';
    for k = 1:starsNum
        msg(k) = '*';
    end
    
    if (strcmp(lower(msgValueType), 'string'))
        fprintf('\n %10s %-20s (%10s %s): %40s', direction, msgLabel, msgValueType, msgValue, msg);
    elseif (strcmp(lower(msgValueType), 'boolean'))
        if (msgValue)
            fprintf('\n %10s %-20s (%10s TRUE ): %40s', direction, msgLabel, msgValueType, msg);
        else
            fprintf('\n %10s %-20s (%10s FALSE): %40s', direction, msgLabel, msgValueType, msg);
        end
    elseif (strcmp(lower(msgValueType), 'numeric'))
        fprintf('\n %10s %-20s (%10s %3d): %40s', direction, msgLabel, msgValueType, msgValue, msg);
    end
    
end

