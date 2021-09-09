% Method to initialize communication with the PR670 (establish communication  part2)
function obj = initCommunication(obj)    
    if (obj.verbosity > 9)
        fprintf('In PR670obj.initCommunication() method\n');
    end

    if (obj.emulateHardware)
        fprintf(2,'PR670obj.initCommunication()- Emulating hardware\n');
        return;
    end
    
    try 
        % Attempt to communicate. 
        % Tell the PR-670 to exit remote mode.  We do this to ensure a response from
        % the device when we go into remote mode.  I've found it only responds the
        % first time it's asked to go into remote mode.  There is no return code
        % for this command.

%         fprintf(2,'\n Sending command ''Q'' to exit remote mode ...');
%         obj.writeSerialPortCommand('commandString', 'Q', ...
%                                    'appendCR', false);
%         pause(1.5);

        fprintf('\nDone. Attempting to put device in remote mode ...')
        % Put in remote mode.
        obj.writeSerialPortCommand('commandString', 'PHOTO', ...
                                   'appendCR', false);

        pause(3.0);
        fprintf('\nWaiting for PR670 to acknowledge remote mode for up to 10 seconds ...\n');
        % Get the response.  Timeout after 10 seconds.  
        timeoutInSeconds = 10;
        response = obj.getResponseOrTimeOut(timeoutInSeconds, '\nFailed to set PR670 in REMOTE  MODE. Disconnect PR670, recycle its power, and try again\n');
        
        if (isempty(response ))
            error('Count not read response from PR670');
        elseif strcmp(response , ' REMOTE MODE')
           fprintf('<strong>Sucessfully established communication with PR670!!</strong>\n\n'); 
        else
            error('*** Wrong response from PR670. \n\tExpected: '' REMOTE MODE''\n\tReceived: ''%s''\n.', response );
        end


        % Write command to export the configuration
        obj.writeSerialPortCommand('commandString', 'D14');
        config = obj.getConfiguration();
        if (obj.verbosity > 1)
            fprintf('Config:\n')
            config
            fprintf('\n');
        end

    catch err
        obj.shutDown();
        rethrow(err)
    end
end