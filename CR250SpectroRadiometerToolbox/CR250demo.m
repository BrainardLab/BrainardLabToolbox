function CR250demo(mode, argument)
% CR250Ademo- Demonstrates the usage of the CR250_device driver for
% controlling the CR250 colorimeter.
%
% Syntax:
% CR250demo
%
% Description:
% CR250demo demostrates the different commands that can be sent to the CR250_device 
%
%  History:
%    April 2025  NPC  Wrote it
%

    validModes = {...
        'compileMexDriver' ...
        'testOpen' ...
        'testToggleEcho' ...
        'testGetDeviceInfo' ...
        'setMinVerbosity' ...
        'setMaxVerbosity' ...
        'setDefaultVerbosity' ...
        };

    switch (mode)
        case 'compileMexDriver'
            compileMexDriver();

        case 'testOpen'
            testOpenDevice();

        case 'testClose'
            testCloseDevice();

        case 'testToggleEcho'
            testToggleEcho();

        case 'testGetDeviceInfo'
            showFullResponse = ~true;
            testGetDeviceInfo('RC ID', showFullResponse);
            testGetDeviceInfo('RC Model', showFullResponse);
            testGetDeviceInfo('RC InstrumentType', showFullResponse);
            testGetDeviceInfo('RC Firmware', showFullResponse);
            testGetDeviceInfo('RS Aperture', showFullResponse);
            testGetDeviceInfo('RC Aperture', showFullResponse);
            testGetDeviceInfo('RC Accessory', showFullResponse);
            testGetDeviceInfo('RC Filter', showFullResponse);
            testGetDeviceInfo('RC SyncMode', showFullResponse);

        case 'testSetSyncMode'
            % Available syncModeNames
            % - 'none'
            % - 'auto'
            % - 'manual'
            % - 'NTSC'
            % - 'PAL'
            % - 'CINEMA'
            if (nargin == 2)
                syncModeName = argument;
            else
                syncModeName = 'none';
            end
            testSetDeviceSyncMode(syncModeName);

        case 'testGetSyncMode'
            % This does not return anything for some reason
            testGetDeviceSyncMode()

        case 'testMeasure'
            showFullResponse = true;
            testTakeTheMeasurement(showFullResponse);

        case 'testRetrieveMeasurement'
            if (nargin == 2)
                measurementType = argument;
            else
                measurementType = 'spectrum';
            end
            testRetrieveTheMeasurement(measurementType);

        case 'testMeasureAndRetrieve'
            if (nargin == 2)
                measurementType = argument;
            else
                measurementType = 'spectrum';
            end
            showFullResponse = true;
            testTakeTheMeasurement(showFullResponse);
            testRetrieveTheMeasurement(measurementType);

        case 'setMinVerbosity'
            setVerbosityLevel('min');

        case 'setMaxVerbosity'
            setVerbosityLevel('max');

        case 'setDefaultVerbosity'
            setVerbosityLevel('default');

        otherwise
            validModes
            error('Passed mode (''%s'') is not known!', mode);
    end % Switch (mode)

end


%% ----- MEASUREMENT FUNCTIONALITY

function  testRetrieveTheMeasurement(measurementType)
    validMeasurementTypes = { ...
        'spectrum' ...
    };

    switch (measurementType)
        case 'spectrum'
            retrieveDataCommandID = 'RM Spectrum';

        otherwise
            validMeasurementTypes
            fprintf(2, 'Unknown measurement type: ''%s''.', measurementType);
    end

    % Retrieve the measurement
    showFullResponse = true;
    % Retrieve the data
    [status, response] = CR250_device('sendCommand', retrieveDataCommandID);
    response
    status
end

function testTakeTheMeasurement(showFullResponse)
    Speak('Measuring')
    tic
    % Conduct a measurement
    commandID = 'M';
    [status, response] = CR250_device('sendCommand', commandID);
    if ((status == 0) && (~isempty(response) > 0))
        [parsedResponse, fullResponse] = parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
        if (showFullResponse)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

    doneText = sprintf('Measurement took %2.1f seconds\n', toc);
    Speak(doneText);
    disp(doneText);
end

function testSetDeviceSyncMode(syncModeName)
    validSyncModeNames = {...
        'none' ...
        'auto' ...
        'manual' ...
        'NTSC' ...
        'PAL' ...
        'CINEMA' ...
    };

    switch (syncModeName)
        case 'none'
            syncModeID = 0;
        case 'auto'
            syncModeID = 1;
        case 'manual'
            syncModeID = 2;
        case 'NTSC'
            syncModeID = 3;
        case 'PAL'
            syncModeID = 4;
        case 'CINEMA'
            syncModeID = 5;
        otherwise
            validSyncModeNames 
            fprintf(2, 'Unknown sync mode: ''%s''.', syncModeName);
    end % switch mode

    % Set the sync mode
    commandID = sprintf('SM SyncMode %d', syncModeID);
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse] = parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

    testGetDeviceSyncMode()
end

function testGetDeviceSyncMode()
    % Retrieve the sync mode
    commandID = sprintf('RS SyncMode');
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse] = parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end


%% ----- BASIC FUNCTIONALITY ----
function setVerbosityLevel(theLevel)
     % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    switch (theLevel)
        case 'min'
            status = CR250_device('setVerbosityLevel', 1);
        case 'default'
            status = CR250_device('setVerbosityLevel', 5);
        case 'max'
            status = CR250_device('setVerbosityLevel', 10);
        otherwise
            fprintf(2,'Unknown verbosity level: ''%s''. Select ''min'', ''default'', or ''max''.', theLevel);

    end % switch (theLevel)
end

function testOpenDevice()
    serialDeviceID = '/dev/tty.usbmodemA009271';

    % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    status = CR250_device('setVerbosityLevel', 10);

    % ------ OPEN THE CR250 device ----------------------------------------------
    status = CR250_device('close');
    status = CR250_device('open', serialDeviceID);
    if (status == 0)
        disp('Opened CR250 port');
    elseif (status == -1)
        disp('Could not open CR250 port');
    elseif (status == 1)
        disp('CR250 port was already opened');
    elseif (status == -99)
        disp('Invalided serial port');
    end

    % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
    speed     = 115200;
    wordSize  = 8;
    parity    = 0;
    timeOut   = 0;
    
    status = CR250_device('updateSettings', speed, wordSize, parity,timeOut); 
    if (status == 0)
        disp('Updated communication settings in CR250 port');
    elseif (status == -1)
        disp('Could not update settings in CR250 port');
    elseif (status == 1)
        disp('CR250 port is not open');
    end

    % ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
    [status, dataRead] = CR250_device('readPort');
    if ((status == 0) && (length(dataRead) > 0))
        fprintf('Read data: %s\n', dataRead);
    elseif (status ~= 0)
        fprintf(2, 'Failed reading from the port!!!. Status = %d!!!', status);
    end

end  % testOpenDevice

function testCloseDevice()
    status = CR250_device('close');
    if (status == 0)
       disp('Closed previously-opened CR250 port');
    elseif (status == -1)
       disp('Could not close previously-opened CR250 port');
    end
end


function testToggleEcho()
    % Toggle the echo state
    [status, deviceID] = CR250_device('sendCommand', 'E');
end


function testGetDeviceInfo(commandID, showFullResponse)
    % Send the command
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse] = parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
        if (showFullResponse)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end
end


function [parsedResponse, fullResponse] = parseResponse(response, commandID)
    
    fullResponse = response;

    % Remove 'OK:0: prefix
    prefixString = 'OK:0:';
    response = strrep(response, prefixString, '');

    % Remove commandID which is replicated
    response = strrep(response, sprintf('%s:',commandID), '');

    % find how many lines is contained in the response
    indexOfRETURNkeys = find(response == 13);

    iBegin = 1;
    parsedResponse = {};
    for responseLine = 1:numel(indexOfRETURNkeys)
        iEnd = indexOfRETURNkeys(responseLine);
        parsedResponse{responseLine} = char(response(iBegin:(iEnd-1)));
        iBegin = iEnd+2;
    end
end




    
%%  COMPILE MEX DRIVER
function compileMexDriver()
    disp('Compiling CR250 device driver ...');
    currentDir = pwd;
    programName = 'CR250demo.m';
    d = which(programName);
    k = findstr(d, programName);
    d = d(1:k-1);
    cd(d);
    mex('CR250_device.c');
    cd(currentDir);
    disp('CR250 device MEX driver compiled sucessfully!');
end % compileMexDriver()


    
