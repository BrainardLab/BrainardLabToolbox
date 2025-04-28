% Set CR250-specific options
function obj = setOptions(obj, varargin)

    if (~isempty(varargin))
        % Configure an inputParser to examine whether the options passed to us are valid
        parser = inputParser;
        parser.addParameter('syncMode',  obj.syncMode);
        parser.addParameter('manualSyncFrequency', obj.manualSyncFrequency);
        parser.addParameter('speedMode', obj.speedMode);
        parser.addParameter('exposureMode', obj.exposureMode);
        parser.addParameter('fixedExposureTimeMilliseconds', obj.fixedExposureTimeMilliseconds);
        parser.addParameter('verbosity', obj.verbosity);
        % Execute the parser
        parser.parse(varargin{:});
        % Create a standard Matlab structure from the parser results.
        parserResults = parser.Results;
        pNames = fieldnames(parserResults);
        for k = 1:length(pNames)
            fprintf('setOptions: about to set %s\n',pNames{k});
            obj.(pNames{k}) = parserResults.(pNames{k});
        end
    end
end