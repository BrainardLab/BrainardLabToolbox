% Method to search all known portDeviceNames to determine whether there is a match for the attached serial devices
%
function obj = privateGetPortString(obj)
    % For each serial type in the portDeviceNames cell array, see if any attached serial
    % devices names match.
    indices = find(contains({obj.portDeviceFiles.name},obj.portDeviceNames));

    % Throw error if no matching device file was found
    if (isempty(indices))
        obj.portDeviceNames
        for j = 1:length(obj.portDeviceFiles)
            obj.portDeviceFiles(j).name
        end
        error('No devices found. Make sure that your radiometer is plugged in.');
    end

    % Print which ports we have found
    fprintf('Ports found:\n');
    for k = 1:length(indices)
        fprintf('[%d]: %s\n', k, obj.portDeviceFiles(indices(k)).name);
    end

    obj.portString = sprintf('/dev/%s',obj.portDeviceFiles(indices(1)).name);
    fprintf('Will attempt to open %s.\n', obj.portString);
end % getPortString