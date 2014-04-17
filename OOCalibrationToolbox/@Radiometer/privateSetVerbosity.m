% Method to set the verbosity level
function verbosity = privateSetVerbosity(obj,new_verbosity)
    if isnumeric(new_verbosity)
        if (new_verbosity < 0)
            verbosity = 0;
        elseif (new_verbosity > 10)
            verbosity = 10;
        else
            verbosity = new_verbosity;
        end
    else
        error('Propery ''verbosity'' must be a numeric value in [0 .. 10]'); 
    end
            
end