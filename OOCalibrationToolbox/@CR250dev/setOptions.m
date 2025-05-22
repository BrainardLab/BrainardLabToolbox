% Set CR250-specific options
function obj = setOptions(obj, varargin)

    if (~isempty(varargin))
        % Configure an inputParser to examine whether the options passed to us are valid
        parser = inputParser;
        parser.addParameter('syncMode',  [], @(x)(isempty(x)||(ismember(x, obj.validSyncModes))));
        parser.addParameter('manualSyncFrequency', @(x)(isempty(x)||(isscalar(x) && (x>=10) && (x<=10*1000))));
        parser.addParameter('speedMode', [],  @(x)(isempty(x)||(ismember(x, obj.validSpeedModes))));
        parser.addParameter('exposureMode', [],  @(x)(isempty(x)||(ismember(x, obj.validExposureModes))));
        parser.addParameter('fixedExposureTimeMilliseconds', []);
        parser.addParameter('verbosity',[]);

        % Execute the parser
        parser.parse(varargin{:});
        % Create a standard Matlab structure from the parser results.
        parserResults = parser.Results;
        pNames = fieldnames(parserResults);

        for k = 1:length(pNames)
            if (~isempty(parserResults.(pNames{k})))
                fprintf('setOptions: about to set %s\n',pNames{k});
                if (contains(lower(pNames{k}), 'exposure'))
                    pause(1);
                end
                obj.(pNames{k}) = parserResults.(pNames{k});
            end
        end
    end
end