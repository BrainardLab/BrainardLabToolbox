% Method to initialize communication with the PR670 (establish communication  part2)
function obj = initCommunication(obj)    
    if (obj.verbosity > 9)
        fprintf('In PR670obj.initCommunication() method\n');
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

        fprintf(2,'\nDone. Attempting to put device in remote mode ...')
        % Put in remote mode.
        obj.writeSerialPortCommand('commandString', 'PHOTO', ...
                                   'appendCR', false);

        pause(3.0);
        fprintf(2,'\n Waiting for PR670 to acknowledge remote mode for up to 10 seconds ...');
        % Get the response.  Timeout after 10 seconds.  
        timeoutInSeconds = 10;
        response = obj.getResponseOrTimeOut(timeoutInSeconds, 'Failed to set PR670 in REMOTE  MODE') ;   

        % Try once more
        if (isempty(response ))
            fprintf('No response. Will try to put device in remote mode once more\n');
            obj.writeSerialPortCommand('commandString', 'PHOTO', ...
                                   'appendCR', false);
                               
           fprintf(2,'\n Waiting for PR670 to acknowledge remote mode for up to 10 seconds ...');
            % Get the response.  Timeout after 10 seconds.  
            timeoutInSeconds = 10;
            response = obj.getResponseOrTimeOut(timeoutInSeconds, 'Failed to set PR670 in REMOTE  MODE') ;   
        end
        
        fprintf(2,'\n Response received:\n')
        response

        
        if (isempty(response ))
            error('Count not read response from PR670');
        elseif strcmp(response , ' REMOTE MODE')
           fprintf('Sucessfully established communication with PR670!!\n\n'); 
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
        fprintf('Hit enter to continue\n')
        pause

    catch err
        obj.shutDown();
        rethrow(err)
    end
end