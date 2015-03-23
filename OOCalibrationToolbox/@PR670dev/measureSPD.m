function measureSPD(obj)
%
    if (obj.verbosity > 9)
        fprintf('In PR670obj.measureSPD() method\n');
    end
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
    
    % Send the measurement command
    obj.writeSerialPortCommand('commandString', 'M5');

    % Read back the data
    timeout = 300;
    StartTime = GetSecs;
    waited = GetSecs - StartTime;
    inStr = [];
    while isempty(inStr) && waited < timeout
        inStr = obj.readSerialPortData;
        waited = GetSecs - StartTime;
    end

    if waited == timeout
        error('Unable to read SPD data from PR670.');
    else
        readStr = inStr;
    end

    % Extract the result code.
    qual = sscanf(readStr, '%f', 1);
    
    switch qual
        case 0 % Measurement OK
            
            % Split up the data delimited by newline characters.
            C = textscan(readStr, '%s', 'Delimiter', '\n');
            C = C{1};

            % Loop over all the data lines and pull out the spectral info.  Note that
            % the first line doesn't contain wavelength data so we toss it.
            C = C(2:end);
            nativeSamples = length(C);
    
            if (nativeSamples ~= obj.nativeS(3))
                error('Unexpected native number of wavelength samples for PR-670. Expected %d, found %d.', obj.nativeS(3), nativeSamples);
            end
    
            for k = 1:nativeSamples
                % Parse the wavelength measurement line.  The first element of the
                % returned cell array will be the wavelength, the second element the
                % measurement.
                D = textscan(C{k}, '%d,%f');
                obj.nativeMeasurement.spectralAxis(k) = D{1};
                obj.nativeMeasurement.energy(k) = D{2};
            end

            % update nativeS (in case it was incorrectly set in the constructor)
            obj.nativeS = WlsToS(obj.nativeMeasurement.spectralAxis);
                
            % Convert to our units standard, i.e., multiply by sampling interval
            obj.nativeMeasurement.energy = obj.nativeS(2) * obj.nativeMeasurement.energy;
                
        case -8 % Too dark
            fprintf('>>> Quality code: %d. Low light level!. Returning zeros.\n', qual);
            % return zeros
            nativeSamples = obj.nativeS(3);
            obj.nativeMeasurement.spectralAxis = StoWls(obj.nativeS);
            obj.nativeMeasurement.energy = zeros(1,nativeSamples);
            
        case {-1, -10}  % Light source sync failure
            error('Could not sync to source. Turning off ''AUTO'' sync mode.\n');
            
        otherwise
            error('Bad return code %g from meter', qual);
    end
end


