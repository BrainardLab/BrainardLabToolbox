function result = getMeasuredData(obj, varargin)

    % initialize to empty result
    result = [];
    
    % Get response or time-out after 30 seconds
    timeOutPeriodInSeconds = 30;
    startTime = GetSecs;
    serialData = [];
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = [serialData obj.readSerialPortData()];
    end
    if (isempty(serialData))
        fprintf('Raw SPD measurement timed-out after %2.1f seconds.\n', timeOutPeriodInSeconds);
    else
        % Get the data
        IOPort('write', obj.portHandle, ['d5' char(10)]);
        WaitSecs(0.1);
        serialData = [];
        while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
            serialData = [serialData obj.readSerialPortData()];
        end
        if (isempty(serialData))
            fprintf('Could not get data. Timed out after %2.1f seconds.\n', timeOutPeriodInSeconds);
        else
            if (obj.verbosity > 9)
                fprintf('Raw SPD data obtained: ');
                serialData
            end
            
            % Parse data 
            qual = sscanf(serialData,'%f',1);
            if ((qual == 7) || (qual == 8))
                error('>>>Quality code:%f\n', qual);
                
            elseif ((qual == -1) || (qual == 10))
                fprintf('>>> Quality code: %f. Low light level!. Returning zeros\n', qual);
                % return zeros
                nativeSamples = obj.nativeS(3);
                obj.nativeMeasurement.spectralAxis = zeros(1,nativeSamples);
                obj.nativeMeasurement.energy = zeros(1,nativeSamples);
            
            elseif ((qual == 18) || (qual == 0))
                start = findstr(serialData,'0380.');
                
                nativeSamples = obj.nativeS(3);
                obj.nativeMeasurement.spectralAxis = zeros(1,nativeSamples);
                obj.nativeMeasurement.energy = zeros(1,nativeSamples);
                
                for k = 1:nativeSamples
                    %fprintf('k: %d, bi: %d, ed: %d\n', k, start+6+17*(k-1), start+6+9+17*(k-1));
                    obj.nativeMeasurement.spectralAxis(k) = str2num(serialData(start+17*(k-1):start+5+17*(k-1)));
                    obj.nativeMeasurement.energy(k)       = str2num(serialData(start+6+17*(k-1):start+6+9+17*(k-1)));
                end

                % update nativeS (in case it was incorrectly set in the constructor)
                obj.nativeS = [obj.nativeMeasurement.spectralAxis(1) ...
                               obj.nativeMeasurement.spectralAxis(2)-obj.nativeMeasurement.spectralAxis(1) ...
                               length(obj.nativeMeasurement.spectralAxis)];

                % Convert to our units standard.
                obj.nativeMeasurement.energy = 4 * obj.nativeMeasurement.energy;
            else
                error('Bad return code %g from meter', qual);
            end

        end
    end
    
    
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