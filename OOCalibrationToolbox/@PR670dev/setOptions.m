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
        parser.addParamValue('exposureTime',    obj.privateExposureTime);
        parser.addParamValue('apertureSize',    obj.privateApertureSize);
        
        % Execute the parser
        parser.parse(varargin{:});
        % Create a standard Matlab structure from the parser results.
        parserResults = parser.Results;
        pNames = fieldnames(parserResults);
        
        % Read the old FULL configuration
        if (obj.verbosity > 1)
            previousConfig = obj.getConfiguration()
        end
    
        % Set the options
        % Make sure we set the sensitivity mode first
        % because the exposureTime depends appropriate setting of the sensitivityMode
        obj.sensitivityMode = parserResults.sensitivityMode;
        
        % Then set all the others
        for k = 1:length(pNames)
            if ~(strcmp(pNames{k}, 'sensitivityMode'))
                obj.(pNames{k}) = parserResults.(pNames{k});
            end
        end
        
        if (obj.verbosity > 1)
            updatedConfig = obj.getConfiguration()
        end
        
    end
end
