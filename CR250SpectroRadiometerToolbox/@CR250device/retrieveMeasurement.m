% Method to retrieve a measurement

%  History:
%    April 2025  NPC  Wrote it

function [theSpectralSupport, theSpectrum] = retrieveMeasurement(obj)
    
    theSpectralSupport = [];
    theSpectrum = [];

    Speak('Retrieving data. Please wait.')
    tic

    switch (obj.measurementTypeToRetrieve)
        case 'spectrum'
            commandID = 'RM Spectrum';

        otherwise
            obj.validMeasurementTypes
            fprintf(2, 'Unknown measurement type: ''%s''.', measurementType);
    end

    % Retrieve the measurement
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
            doneText = sprintf('\nRetrieved data after %2.1f seconds\n', toc);
            Speak(doneText);
        else
            % Report back
            doneText = sprintf('\nSomething is not quite right after retrieving the data\n');
            Speak(doneText);
            disp(doneText);
            fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, responseLines);
            for iResponseLine = 1:numel(parsedResponse)
                fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
            end
        end

        if (obj.showDeviceFullResponse)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        doneText = sprintf('\nRetrieve data command failed\n');
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
