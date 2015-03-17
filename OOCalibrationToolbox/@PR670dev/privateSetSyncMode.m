% Method to set a new value for the syncMode property
function obj = privateSetSyncMode(obj, newSyncMode)
    
    if (obj.verbosity > 9)
        fprintf('In privateSetSyncMode\n');
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end

    % Check validity of newSyncMode
    if isnumeric(newSyncMode)
        freqRange = obj.validSyncModes{3};
        
        if ((newSyncMode < freqRange(1)) || (newSyncMode > freqRange(2)))
           error('Sync mode must be in the range [%d - %d] (Hz)', freqRange(1), freqRange(2));
        end
       
        % Tell the device we're specifying a user defined frequency.
        obj.writeSerialPortCommand('commandString', 'SS3');

        % Check the response.
        obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SS3 command');

        % Send the frequency over.
        obj.writeSerialPortCommand('commandString', sprintf('SK%.3d', newSyncMode));

        % Check the response.
        obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SK command');

    elseif ischar(newSyncMode)
        if (~ismember(newSyncMode, {obj.validSyncModes{1}, obj.validSyncModes{2}}))
           error('Sync mode must be set to either a numeric value, ''%s'', or ''%s'' !', obj.validSyncModes{1}, obj.validSyncModes{2}); 
        end
        
        if (strcmp(newSyncMode, 'AUTO'))
            % See if we can sync to the source and set sync mode appropriately.
            sourceFreq = obj.measureSourceFrequency();
            if (~isempty(sourceFreq))
                % AUTO SYNC
                obj.writeSerialPortCommand('commandString', 'SS1');
            else
                % NO SYNC
                obj.writeSerialPortCommand('commandString', 'SS0');
            end
            % Check the response.
            obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SS1 command');
            
            if (~isempty(sourceFreq))
                fprintf('Sync frequency set to AUTO (source measured to be around %2.2f Hz)\n', sourceFreq);
            else
                fprintf(2,'**Sync frequency set OFF (could not measure source frequency\n**');
            end
            
        else
            % NO SYNC
            obj.writeSerialPortCommand('commandString', 'SS0');
            % Check the response.
            obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SS0 command');
        end

    else
        error('Sync mode must be set to a numeric value (e.g., 66), ''AUTO'', or ''OFF'' !');
    end 
        
    % update the private copy
    obj.privateSyncMode = newSyncMode;
end



