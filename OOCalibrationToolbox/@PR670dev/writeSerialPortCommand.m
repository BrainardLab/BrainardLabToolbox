% Method to write a command to the serial port  of the PR670
% By default, it appends a carriage return (CR) to the end of the string.  
% Note that if the CR is already there, it won't be appended. 
% The CR can be disabled as some commands do not need it.  
% See the PR-670 documentation for which command need the CR.
%
% Example usages: 
% obj.writeSerialPortCommand('commandString', 'Q', 'appendCR', false);
% obj.writeSerialPortCommand('commandString', 'D110');

function writeSerialPortCommand(obj, varargin)
    if (obj.verbosity > 9)
        fprintf('In PR670obj.writeSerialPortData() method\n');
    end
    
    parser = inputParser;
    parser.addParamValue('commandString', '');
    parser.addParamValue('appendCR',  true);
    % Execute the parser
    parser.parse(varargin{:});
    % Create a standard Matlab structure from the parser results.
    p = parser.Results;
    commandString = p.commandString;
    appendCR      = p.appendCR;

    if appendCR
        % Check for the CR and add if necessary.
        if commandString(end) ~= char(13)
            commandString = [commandString char(13)];
            if (obj.verbosity > 9)
                fprintf('Appended CR to serial port command\n');
            end
        end
    end

    if (obj.verbosity > 9)
        fprintf('Will send the following command: ''%s'' (%d chars)\n', commandString, length(commandString));
    end

    % Write sequence of chars to PR-670.
    for i = 1:length(commandString)
        if (obj.verbosity > 9)
            fprintf('*** About to write char %d = %s\n', i, commandString(i));
        end
        IOPort('Write', obj.portHandle, upper(commandString(i)));
        pause(0.05)
    end

end
