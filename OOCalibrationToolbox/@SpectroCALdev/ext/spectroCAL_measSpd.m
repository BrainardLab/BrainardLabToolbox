function meas = spectroCAL_measSpd(usbPort, S)
% meas = spectroCAL_measSpd(usbPort, S)
%
% Take a measurement with the SpectroCAL device.
%
% 8/31/2017     ms      Written.

% Check if there is actually a USB port
spectroCAL_checkPort(usbPort);

% Check that the step sizes are 1 or 5 nm
if ~ismember(S(2), [1 5])
    error('Step size not allowed');
end

% Convert to wls
wls = S(1):S(2):(S(1)+S(2)*S(3)-1);

% Check that we can actually take this measurement
[startWlSys stopWlSys] = SpectroCALGetCapabilities(usbPort);
if startWlSys > wls(1)
    error('Start wavelength: Out of range');
end

if stopWlSys < wls(end)
    error('End wavelength: Out of range');
end

% Take the measurement using a call to CRS's toolbox function.
tic;
fprintf('* <strong>Starting measurement...</strong>\n');
[meas.ciexy, meas.cieuv, meas.luminance, meas.wls, meas.spd] = SpectroCALMakeSPDMeasurement(usbPort, wls(1), wls(end), S(2));
meas.timeElapsed = toc;
fprintf('- <strong>Done!</strong> Time elapsed: %f.\n', meas.timeElapsed);