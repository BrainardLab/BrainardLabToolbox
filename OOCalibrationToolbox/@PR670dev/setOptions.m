% Method to Set PR670-specific options
function obj = setOptions(obj, varargin)

    if (obj.verbosity > 9)
        fprintf('In PR670obj.setOptions() method\n');
    end
    
    
    if (~isempty(varargin))
        % Configure an inputParser to examine whether the options passed to us are valid
        parser = inputParser;
        parser.addParamValue('verbosity',       obj.verbosity);
        parser.addParamValue('syncMode',        obj.privateSyncMode);
        parser.addParamValue('cyclesToAverage', obj.privateCyclesToAverage);
        parser.addParamValue('sensitivityMode', obj.privateSensitivityMode);
        parser.addParamValue('apertureSize',    obj.privateApertureSize);
        
        % Execute the parser
        parser.parse(varargin{:});
        % Create a standard Matlab structure from the parser results.
        parserResults = parser.Results;
        pNames = fieldnames(parserResults);
        
        % Read the old FULL configuration
        oldConfig = obj.getConfiguration();
        if (obj.verbosity > 1)
           fprintf('Old config: ''%s'' \n', oldConfig); 
        end
    
        % Set the options
        for k = 1:length(pNames)
            obj.(pNames{k}) = parserResults.(pNames{k});
        end
        
        % Read the new FULL configuration
        newConfig = obj.getConfiguration();
        if (obj.verbosity > 1)
            fprintf('New config: ''%s'' \n', newConfig); 
        end
    
    end
end
