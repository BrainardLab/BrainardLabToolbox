% Set up dependencies with TbTb
tbUse('OxfordPerceptionLabToolbox');

% Define the USB port
usbPort = '/dev/tty.usbserial-AL1G0I9F';

[~, ~, ~, ~, spd(:, ii)] = SpectroCALMakeSPDMeasurement(usbPort, 380, 780, 1);

% Do the measurement
S = [380 1 401];
meas = spectroCAL_measSpd(usbPort, S);

%%
% Turn on or off the laser
error = SpectroCALLaserOn(usbPort);
error = SpectroCALLaserOff(usbPort);


[~, ~, ~, ~, spd(:, ii)] = SpectroCALMakeSPDMeasurement(usbPort, 380, 780, 1);