function measureSPD(obj)
%
    if (obj.verbosity > 9)
        fprintf('In CR250obj.measureSPD() method\n');
    end
    
    nativeSamples = obj.nativeS(3);
    obj.nativeMeasurement.spectralAxis = zeros(1,nativeSamples);
    obj.nativeMeasurement.energy = zeros(1,nativeSamples);
                
    doTheMeasurement(obj);
    [theSpectralSupport, theSpectrum] = retrieveTheMeasurement(obj);

    obj.nativeMeasurement.spectralAxis = theSpectralSupport;
    obj.nativeMeasurement.energy = theSpectrum;    
    obj.measurementQuality = [];


    % update nativeS (in case it was incorrectly set in the constructor)
    % obj.nativeS = WlsToS((obj.nativeMeasurement.spectralAxis)');

    % Convert to our units standard, i.e., multiply by sampling interval
    obj.nativeMeasurement.energy = obj.nativeS(2) * obj.nativeMeasurement.energy;

end


function doTheMeasurement(obj)
    Speak('Measuring.')

    % Conduct a measurement
    commandID = 'M';
    [status, response] = CR250_device('sendCommand', commandID);


    if (contains(response, 'OK:0:M:No errors'))
    else
        fprintf(2, '>>>> Measure command returned: ''%s'' (a warning).\n', response);
        fprintf(2, '>>>> Check manual for interpretation of this warning message.\n')
    end


    % Wait for response
    if ((status == 0) && (~isempty(response) > 0))
        [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
        if (obj.verbosityIsNotMinimum)
            fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        
            for iResponseLine = 1:numel(parsedResponse)
                fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
            end
            if (obj.showDeviceFullResponse) && (obj.verbosityIsNotMinimum)
                fprintf('\nFull response: ''%s''.', fullResponse);
            end
        end
        doneText = sprintf('Done');
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
        doneText = sprintf('Failed');
    end

    % Report back
    Speak(doneText);
    disp(doneText);
end



function [theSpectralSupport, theSpectrum] = retrieveTheMeasurement(obj)

    theSpectralSupport = [];
    theSpectrum = [];

    Speak('Retrieving.')
    tic

    % Retrieve the spectrum measurement
    commandID = 'RM Spectrum';
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);
        
        if (~responseIsOK)
            fprintf(2, 'Device response to retrieving the data is NOT OK !! \n');
            Speak('Data are compromised');
        end

        responseLines = numel(parsedResponse);
        if (responseLines == 202)
            % Perfect spectral response. Parse it out
            [theSpectralSupport, theSpectrum] = parseSpectralData(parsedResponse);
            % Report back
            doneText = sprintf('Done');
            Speak(doneText);
        else
            % Report back
            doneText = sprintf('\nSomething is not quite right after retrieving the data\n');
            Speak(doneText);
            disp(doneText);
            if (obj.verbosityIsNotMinimum)
                fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, responseLines);
                for iResponseLine = 1:numel(parsedResponse)
                    fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
                end
            end
        end

        if (obj.showDeviceFullResponse) && (obj.verbosityIsNotMinimum)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        doneText = sprintf('Failed');
        Speak(doneText);
        disp(doneText);
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end


function [theSpectralSupport, theSpectrum] = parseSpectralData(parsedResponse)
    lineNo = 1;
    theSpectralSupportString = parsedResponse{lineNo};
    theLineSubString = sprintf('Line-%d:', lineNo);
    theSpectralSupportString = strrep(theSpectralSupportString, theLineSubString, '');
    theSpectralSupport = extractNumFromStr(theSpectralSupportString);
    theSpectralSupport = theSpectralSupport(1):theSpectralSupport(3):theSpectralSupport(2);

    for lineNo = 2:numel(parsedResponse)
        theEnergyString = parsedResponse{lineNo};
        theLineSubString = sprintf('Line-%d', lineNo);
        theEnergyString = strrep(theEnergyString, theLineSubString, '');
        theSpectrum(lineNo-1) = extractNumFromStr(theEnergyString);
    end
end


function numArray = extractNumFromStr(str)
    str1 = regexprep(str,'[,;=]', ' ');
    str2 = regexprep(regexprep(str1,'[^- 0-9.eE(,)/]',''), ' \D* ',' ');
    str3 = regexprep(str2, {'\.\s','\E\s','\e\s','\s\E','\s\e'},' ');
    numArray = str2num(str3);
end



function fromPR650()
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
            obj.measurementQuality = qual;
            
            if ((qual == 7) || (qual == 8))
                error('>>>Quality code:%f\n', qual);
                
            elseif ((qual == -1) || (qual == 10))
                fprintf('>>> Quality code: %f. Low light level!. Returning zeros\n', qual);
                % return zeros
                nativeSamples = obj.nativeS(3);
                obj.nativeMeasurement.spectralAxis = SToWls(obj.nativeS);
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
                % obj.nativeS = WlsToS((obj.nativeMeasurement.spectralAxis)');

                % Convert to our units standard, i.e., multiply by sampling interval
                obj.nativeMeasurement.energy = obj.nativeS(2) * obj.nativeMeasurement.energy;
            else
                error('Bad return code %g from meter', qual);
            end

        end
    end
end 