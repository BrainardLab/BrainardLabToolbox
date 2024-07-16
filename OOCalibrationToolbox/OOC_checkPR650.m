function OOC_checkPR650(varargin)

    if (nargin == 0)
        verb = 0;
    else
        verb = varargin{1};
        if (isnumeric(verb) && verb >= 0 && verb <= 10)
        else
            verb = 0;
        end
    end

    pr650obj = [];
    devicePortString = []; %'/dev/tty.KeySerial1';  % or select from ls -a /dev/cu*, e.g. '/dev/cu.usbmodem1a21'
    
    try
        pr650obj = PR650dev('verbosity', verb, 'devicePortString', devicePortString);
        fprintf('<strong>Hit enter to close device: </strong>');
        pause
        fprintf('Please wait ...');
        pr650obj.shutDown();
        
    catch err
        fprintf('<strong>\nEncountered the following error: %s</strong>\n', err.message);
        if (~isempty(pr650obj))
            pr650obj.shutDown();
        end
        rethrow(err);
    end
    
end

