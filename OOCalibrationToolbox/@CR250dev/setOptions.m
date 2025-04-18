% Set CR250-specific options
function obj = setOptions(obj, varargin)
    if (~isempty(varargin))
        % Configure an inputParser to examine whether the options passed to us are valid
        parser = inputParser;
        parser.addParameter('syncMode',  obj.syncMode);
        parser.addParameter('verbosity', obj.verbosity);
        % Execute the parser
        parser.parse(varargin{:});
        % Create a standard Matlab structure from the parser results.
        parserResults = parser.Results;
        pNames = fieldnames(parserResults);
        for k = 1:length(pNames)
            obj.(pNames{k}) = parserResults.(pNames{k});
        end
    end
end