function meas = spectroCAL_checkPort(usbPort)
% meas = spectroCAL_checkPort(usbPort, S)
%
% Check if the port exists and perhaps suggest another one.
%
% 8/31/2017     ms      Written.

try
    tmp = ls(usbPort);
    fprintf('Device found at <strong>%s</strong>\n', strtrim(tmp));
catch e
    fprintf(sprintf('No device found at <strong>%s</strong>, port does not exist\n', usbPort));
    fprintf('Potential devices in /dev/tty:\n');
    tmp = dir('/dev/tty*usb*');
    for ii = 1:length(tmp)
        fprintf('\t<strong>%s</strong>\n', fullfile(tmp.folder, tmp.name));
    end
    error('Exiting...');
end