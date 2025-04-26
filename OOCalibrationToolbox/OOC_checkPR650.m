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
    if (IsLinux)
        devicePortString = '/dev/ttyUSB0';  % or select from ls -a /dev/cu*, e.g. '/dev/cu.usbmodem1a21'
    end
    
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

