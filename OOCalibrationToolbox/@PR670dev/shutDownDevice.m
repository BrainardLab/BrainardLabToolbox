% Method to shutdown the device
function obj = shutDownDevice(obj)
    if (obj.verbosity > 9)
        fprintf('In PR670obj.shutDown() method\n');
    end
    
    if (obj.emulateHardware)
        fprintf(2,'PR670obj.shutDownDevice()- Emulating hardware\n');
        return;
    end
    
    if (~isempty(obj.portHandle))
        pause(2.0);
        obj.writeSerialPortCommand('commandString', 'Q', 'appendCR', false);
        pause(5.0);
        IOPort('Close', obj.portHandle);
        obj.portHandle = [];
        fprintf('Closed connection to PR670\n');
    end
end