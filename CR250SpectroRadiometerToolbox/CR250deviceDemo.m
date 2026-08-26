function CR250deviceDemo
% CR250deviceDemo- Demonstrates the usage of the @CR250device for
% controlling the CR250 colorimeter.
%
% Syntax:
% CR250deviceDemo
%
% Description:
% CR250deviceDemo demostrates the different commands that can be sent to the @CR250device 
%
%  History:
%    April 2025  NPC  Wrote it
%

% Compile the MEX driver
CR250device.compileMexDriver();


% Open the CR250
theCR250dev = CR250device(...
    'verbosity', 'min');

% Set the verbosity to maximum
theCR250dev.verbosity = 'min';
  
% See what is the range of exposureTime
theCR250dev.exposureTimeRange

% See what exposureModes are supported
theCR250dev.validExposureModes

theCR250dev.fixedExposureTimeMilliseconds = 100;

theCR250dev.exposureTimeRange

% Set the exposure mode to 'Fixed'
theCR250dev.exposureMode = 'Fixed';

% Set the exposure mode to 'Fixed'
theCR250dev.exposureMode = 'Auto';

% Set the sync frequency to some desired number
theCR250dev.manualSyncFrequency = 120.15;

% See what syncModes are supported
theCR250dev.validSyncModes

% Set the sync mode to NTSC
theCR250dev.syncMode = 'NTSC';

% See what capture speed modes are supported
theCR250dev.validSpeedModes

% Set the capture speed to 'slow' (to measure a dim light source)
theCR250dev.speed = 'Slow';

% Take an SPD measurement. This will trigger immediately (no delay)
theCR250dev.measure();

% Retrieve the SPD measurements
[theSpectralSupport, theSPD] = theCR250dev.retrieveMeasurement();

figure(1);
bar(theSpectralSupport, theSPD, 1);

% Close the CR250
theCR250dev.close()
