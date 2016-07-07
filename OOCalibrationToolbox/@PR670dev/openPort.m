% Method to open port for PR670 (establish communication  part1)
function obj = openPort(obj)    
    if (obj.verbosity > 9)
        fprintf('In PR670obj.openPort() method\n');
    end
    
    % Attempt to open the port
    handshakeCode = 'Lenient DontFlushOnWrite=1';
    
    oldverbo = IOPort('Verbosity', 2);

    if (isempty(obj.portHandle)) 
        tryToOpen = true;
        attempts = 0;
        maxAttempts = 5;

        try 
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

        catch err
            obj.shutDown();
            rethrow(err)
        end
    end 
end
