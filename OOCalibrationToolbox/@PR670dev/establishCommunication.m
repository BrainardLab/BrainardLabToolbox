% Method to establish communication with the PR670
function obj = establishCommunication(obj)    
    if (obj.verbosity > 9)
        fprintf('In PR670obj.establishCommunication() method\n');
    end
    
    % Attempt to open the port
    handshakeCode = 'Lenient DontFlushOnWrite=1';
    
    oldverbo = IOPort('Verbosity', 2);
    
    if (isempty(obj.portHandle)) 
        tryToOpen = true;
        attempts = 0;
        maxAttempts = 5;

        while (tryToOpen) && (attempts < maxAttempts) && (isempty(obj.portHandle))
            try
                if (obj.verbosity > 9)
                    fprintf('Trying to open port %s...', obj.portString);
                end
                attempts = attempts + 1;
                obj.portHandle = IOPort('OpenSerialPort', obj.portString, handshakeCode);
                tryToOpen = false;
            catch err
                if (obj.verbosity > 9)
                    fprintf('Could not open port. Will try again\n');
                end
                IOPort('CloseAll');
                pause(0.2);
            end
        end
        
        if (attempts == maxAttempts)
            error('Could not open port after %d attempts. Error = %s', maxAttempts, err.message);
        end
        
        if (obj.verbosity > 9)
            fprintf('\n\t1.Opened port %s after %d attempts\n', obj.portString, attempts);
        end
        
        IOPort('Verbosity', oldverbo);
        
        % Check port validity
        obj.checkPortValidity(obj.invalidPortStrings);
        
        % Attempt to communicate. 
        % Tell the PR-670 to exit remote mode.  We do this to ensure a response from
        % the device when we go into remote mode.  I've found it only responds the
        % first time it's asked to go into remote mode.  There is no return code
        % for this command.
        obj.writeSerialPortCommand('commandString', 'Q', ...
                                   'appendCR', false);
        pause(0.5);

        % Put in remote mode.
        obj.writeSerialPortCommand('commandString', 'PHOTO', ...
                                   'appendCR', false);

        % Get the response.  Timeout after 10 seconds.  
        timeoutInSeconds = 10;
        response = getResponseOrTimeOut(obj, timeoutInSeconds, 'Failed to set PR670 in REMOTE  MODE') ;                     

        if (isempty(response ))
            error('Count not read response from PR670');
        elseif strcmp(response , ' REMOTE MODE')
           fprintf('Sucessfully established communication with PR670!!\n\n'); 
        else
            error('*** Wrong response from PR670. \n\tExpected: '' REMOTE MODE''\n\tReceived: ''%s''\n.', response );
        end
        
        try
            % Write command to export the configuration
            obj.writeSerialPortCommand('commandString', 'D14');
            config = obj.getConfiguration();
            if (obj.verbosity > 1)
                fprintf('Config: %s\n', config);
            end
        catch err
            obj.shutDown();
            rethrow(err)
        end
        
    end

end

