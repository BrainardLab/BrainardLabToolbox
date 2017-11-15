function spectroCAL_turnLaserOnOff(usbPort, laserState)
% spectroCAL_turnLaserOnOff(usbPort, laserState)
%
% Turn the laser on or off.
%
% 8/31/2017     ms      Written.

% Check if there is actually a USB port
spectroCAL_checkPort(usbPort);

% Check whether to turn laser on or off
if laserState == 0
    SpectroCALLaserOff(usbPort);
elseif laserState == 1
    SpectroCALLaserOn(usbPort);
end