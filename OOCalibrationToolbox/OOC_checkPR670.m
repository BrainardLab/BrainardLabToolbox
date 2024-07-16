function OOC_checkPR670(varargin)

    if (nargin == 0)
        verb = 0;
    else
        verb = varargin{1};
        if (isnumeric(verb) && verb >= 0 && verb <= 10)
        else
            verb = 0;
        end
    end

    pr670obj = [];

   
    % Device Port String setting:
    % Empty or select the right device from ls -a /dev/cu*, e.g. '/dev/cu.usbmodem1a21' (Mac/Linux)
    % For windows computers, the 'devicePortString' must be set to 'COM1', 'COM2', 'COM3' etc
    % To find out which one, open DeviceManager and look under Ports(COM&LPT)
    % --Nicolas Jun 17,2024
    devicePortString = 'COM5';

    try
        pr670obj = PR670dev('verbosity', verb, 'devicePortString', devicePortString);
        fprintf('<strong>Hit enter to close device: </strong>');
        pause
        fprintf('Please wait ...');
        pr670obj.shutDown();
        
    catch err
        fprintf('<strong>\nEncountered the following error: %s</strong>\n', err.message);
        if (~isempty(pr670obj))
            pr670obj.shutDown();
        end
        rethrow(err);
    end
    
end

