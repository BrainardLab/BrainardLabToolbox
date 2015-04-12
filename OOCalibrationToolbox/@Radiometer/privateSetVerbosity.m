% Method to set the verbosity level
function privateSetVerbosity(obj,new_verbosity)
    if isnumeric(new_verbosity)
        if (new_verbosity < 0)
            obj.privateVerbosity = 0;
        elseif (new_verbosity > 10)
            obj.privateVerbosity = 10;
        else
            obj.privateVerbosity = new_verbosity;
        end
    else
        error('Propery ''verbosity'' must be a numeric value in [0 .. 10]'); 
    end
            
end