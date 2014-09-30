function measureSPD(obj)
%
    if (obj.verbosity > 9)
        fprintf('In PR650obj.measureSPD() method\n');
    end
    
    % Flush buffers.
    serialData = obj.readSerialPortData();

    % Send command
    IOPort('write', obj.portHandle, ['m0' char(10)]);

    % Get response or time-out after 30 seconds
    timeOutPeriodInSeconds = 30;
    startTime = GetSecs;
    serialData = [];
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = [serialData obj.readSerialPortData()];
    end
    if (isempty(serialData))
        error('Raw SPD measurement timed-out after %2.1f seconds.\n', timeOutPeriodInSeconds);
    else
        % Get the data
        IOPort('write', obj.portHandle, ['d5' char(10)]);
        WaitSecs(0.1);
        serialData = [];
        while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
            serialData = [serialData obj.readSerialPortData()];
        end
        if (isempty(serialData))
            error('Could not get data. Timed out after %2.1f seconds.\n', timeOutPeriodInSeconds);
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
                fprintf('>>> Quality code: %f. Low light level!\n', qual);
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
end 