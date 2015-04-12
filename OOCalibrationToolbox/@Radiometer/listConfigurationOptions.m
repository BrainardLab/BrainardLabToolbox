function listConfigurationOptions(obj)

    fprintf('\n\nAvailable configuration options:\n');
    for k = 1:numel(obj.availableConfigurationOptionNames)
        fprintf('\n''%s'' with the following valid values:', obj.availableConfigurationOptionNames{k});
        validValues = obj.availableConfigurationOptionValidValues{k};
        printValidValues(validValues);
    end
end

function printValidValues(validValues)

    fprintf('\n    ');
    if (iscell(validValues))
        for l = 1:numel(validValues)
            v = validValues{l};
            if (ischar(v))
                fprintf('''%s'' ',v);
            elseif isvector(v)
                if (numel(v) > 1)
                    fprintf('[');
                    for k = 1:numel(v)-1
                        fprintf('%g ', v(k));
                    end
                    fprintf('%g]', v(end));
                else
                    fprintf('%g', v);
                end
            end

           if (l < numel(validValues))
             fprintf(' or  ');
           end
        end
    else
        if (numel(validValues) > 1)
            fprintf('[');
            for k = 1:numel(validValues)-1
                fprintf('%g ', validValues(k));
            end
            fprintf('%g]', validValues(end));
        else
            fprintf('%g', validValues);
        end
    end
    
    fprintf('\n');
end

