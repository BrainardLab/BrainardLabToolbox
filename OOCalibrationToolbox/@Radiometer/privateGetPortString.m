% Method to search all known portDeviceNames to determine whether there is a match for the attached serial devices
%
function obj = privateGetPortString(obj)
    % Enumerate cu* devices - they correspond to serial ports:
    portDeviceFilesCU = dir('/dev/cu*');

    % Enumerate tty.usb* devices - they correspond to serial ports:
    portDeviceFilesTTY_USB = dir('/dev/tty.usb*');    
    
    % Enumerate tty.acm* devices - they correspond to serial ports on Ubuntu linux:
    portDeviceFilesTTYACM = dir('/dev/ttyacm*');    
    
    % Combine port device files
    portDeviceFiles = [portDeviceFilesCU(:); portDeviceFilesTTY_USB(:) portDeviceFilesTTYACM(:)];


    % For each serial type in the portDeviceNames cell array, see if any attached serial
    % devices names match.
    indices = find(contains({portDeviceFiles.name},obj.portDeviceNames));
    
    % Retry with lower device file names
    if (isempty(indices))
        indices = find(contains(lower({portDeviceFiles.name}),obj.portDeviceNames));
    end
    
    % Throw error if no matching device file was found
    if (isempty(indices))
        obj.portDeviceNames
        for j = 1:length(portDeviceFiles)
            portDeviceFiles(j).name
        end
        error('No devices found. Make sure that your radiometer is plugged in.');
    end

    % Print which ports we have found
    fprintf('Ports found:\n');
    for k = 1:length(indices)
        fprintf('[%d]: %s\n', k, portDeviceFiles(indices(k)).name);
    end

    obj.portString = sprintf('/dev/%s',portDeviceFiles(indices(1)).name);
    fprintf('Will attempt to open %s.\n', obj.portString);
end % getPortString