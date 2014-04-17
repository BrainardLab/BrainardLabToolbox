% Method to search all known portDeviceNames to determine whether there is a match for the attached serial devices
%
function obj = privateGetPortString(obj)
    % For each serial type in the portDeviceNames cell array, see if any attached serial
    % devices names match.
    indices = [];
    for i = 1:length(obj.portDeviceNames)
        for j = 1:length(obj.portDeviceFiles)
            if (~isempty(strfind(lower(obj.portDeviceFiles(j).name), obj.portDeviceNames{i})))
                indices = [indices j];
            end
        end
    end

    if (isempty(indices))
        error('No devices found. Make sure that your radiometer is plugged in.');
    end

    numPortsFound = length(indices);
    fprintf('Ports found:\n');
    for k = 1:numPortsFound
        fprintf('[%d]: %s\n', k, obj.portDeviceFiles(indices(k)).name);
    end

    obj.portString = sprintf('/dev/%s',obj.portDeviceFiles(indices(1)).name);
    fprintf('Will attempt to open %s.\n', obj.portString);
end % getPortString