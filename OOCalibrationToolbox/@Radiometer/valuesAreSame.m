% Method to check if two values are same

function  isTrue = valuesAreSame(obj,newValue, oldValue)

    if (isnumeric(newValue))
        if (~isnumeric(oldValue))
            isTrue = false;
        else
            if (newValue == oldValue)
               isTrue = true;
            else
               isTrue = false;
            end
        end
    
    elseif (ischar(newValue))
        if (~ischar(oldValue))
            isTrue = false;
        else
            if (strcmp(newValue,oldValue))
               isTrue = true;
            else
               isTrue = false;
            end
        end
        
    else
        error('Values of class ''%s'' not compared currently.', class(newValue));
    end 
    
end