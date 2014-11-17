% Method to conduct a single native measurent. For the PR-650 this is an SPD measurement.
%
    function result = measure(obj, varargin)
        % initialize to empty result
        result = [];

        % Configure syncMode
        if (strcmp(obj.syncMode, 'ON'))
            if (obj.verbosity > 5)
                disp('Measure with synMode ON');
            end
            syncFreq = obj.measureSyncFreq();
            if (~isempty(syncFreq))
                obj.setSyncFreq(1);
            else
                obj.setSyncFreq(0);
            end
        else
            if (obj.verbosity > 5)
                disp('Measure with synMode OFF');
            end
            obj.setSyncFreq(0);
        end

        % Do the measurement
        obj.measureSPD();

        % By default, the measurement is the native measurement
        obj.measurement = obj.nativeMeasurement;
        applyUserS      = false;
        applyUserT      = false;

        % Parse any additional inputs ( userS and/or userT)
        if (~isempty(varargin))
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParamValue('userS', []);
            parser.addParamValue('userT', []);
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            parserResults = parser.Results;
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
                obj.(pNames{k}) = parserResults.(pNames{k}); 
            end

            if (strcmp(obj.userS, 'native') || isempty(obj.userS))
                obj.userS = obj.nativeS;
            else
               applyUserS = true; 
            end

            if (strcmp(obj.userT, 'native') || isempty(obj.userT))
                obj.userT = obj.nativeT;
            else
               applyUserT = true;
            end
        end

        if (applyUserS || applyUserT)
            if (obj.verbosity > 5)
                fprintf('>>> Measurement transformation was requested <<<\n');
            end
            obj.measurement = obj.transformMeasurement(applyUserS, applyUserT);
        else
            if (obj.verbosity > 5)
                fprintf('>>> Native measurement was requested <<<\n');
            end
            obj.measurement = obj.nativeMeasurement;
        end

        if (isfield(obj.measurement, 'energy'))
            result = obj.measurement.energy;
        else
            result = obj.measurement;
        end
    end