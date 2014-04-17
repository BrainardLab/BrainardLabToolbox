% Method to shutdown the device
function obj = shutDownDevice(obj)
    if (obj.verbosity > 9)
        fprintf('In PR650obj.shutDownDevice() method\n');
    end
    
    if (~isempty(obj.portHandle))
        IOPort('Close', obj.portHandle);
        obj.portHandle = [];
        fprintf('Closed connection to PR650\n');
    end
end