% mglCalibrateMonCommon
%
% This handles everything past the display specific prompting.  Can be called
% by multiple top level interfaces.
%
% 2/12/10  dhb  Pulled out of mglCalibrateMonSpd
%          dhb  Don't pass blankOtherScreen, now part of cal.describe structure.
% 2/13/10  dhb  Same with cal.usebitspp
% 1/11/10  dhb  Email notification as alternative to beeping.
% 10/20/11 tyl, cgb Changed "cal.describe.dacsize =
%                   ScreenDacBits(cal.describe.whichScreen-1);" to "cal.describe.dacsize =
%                   8;" in order to work with 64-bit MATLAB

% Get dacsize
if (cal.usebitspp)
    cal.describe.dacsize = 14;
else
%    cal.describe.dacsize = ScreenDacBits(cal.describe.whichScreen-1);
    cal.describe.dacsize = 8;
end

% Get Brainard Lab standard toolboxes info.
cal.describe.svnInfo = GetBrainardLabStandardToolboxesSVNInfo;

% Fill in descriptive information
computerInfo = GetComputerInfo;
displayDescription = mglDescribeDisplays;
cal.describe.caltype = 'monitor';
cal.describe.computer = sprintf('%s''s %s, %s', computerInfo.userShortName, computerInfo.localHostName, computerInfo.OSVersion);
cal.describe.driver = sprintf('%s %s','unknown_driver','unknown_driver_version');
cal.describe.hz = displayDescription(cal.describe.whichScreen).refreshRate;
cal.describe.screenSizePixel = displayDescription(cal.describe.whichScreen).screenSizePixel;
cal.describe.displayDescription = displayDescription(cal.describe.whichScreen);
if (cal.describe.promptforname)
    cal.describe.who = input('Enter your name: ','s');
end
cal.describe.date = sprintf('%s %s',date,datestr(now,14));
cal.describe.program = sprintf('mglCalibrateMonSpd');

% Check that configuration matches what we expect
if (~isempty(desired.hz))
    if (cal.describe.hz ~= desired.hz)
        error('Current frame rate does not match that specified for this calibraiton\n');
    end
end
if (~isempty(desired.screenSizePixel))
    if (cal.describe.screenSizePixel(1) ~= desired.screenSizePixel(1) || cal.describe.screenSizePixel(1) ~= desired.screenSizePixel(1))
        error('Current resolution does not match that specified for this calibration');
    end
end

% Check for vesigal option that is now ignored
if cal.manual.use
    error('Manual measurements not supported.');
end

% Initialize meter
cal.describe.whichMeterType = whichMeterType;
switch whichMeterType
	case 0
	case 1
		CMCheckInit(whichMeterType);
		if (exist('PR650getserialnumber','file'))
			cal.describe.meterSerialNum = PR650getserialnumber;
		end
	case 2
		CVIOpen;
    case 4
        CMCheckInit(whichMeterType);
    case 5
        CMCheckInit(whichMeterType);
	otherwise
		error('Invalid meter type');
end
ClockRandSeed;

%% Linearize a bits plus box if it in the video chain.  Harmless
% if there is no Bits++ and eliminates ambiguity if there is
% a Bits++ box but we're not using it.
mglBitsResetScreen(cal.describe.whichScreen);

%% Calibrate monitor
% Call a special driver is the calibration is identified as the MondrianHDR
% variation.
if isfield(cal.describe, 'variation') && strcmp(cal.describe.variation, 'MondrianHDR')
	cal = mglCalibrateMondrianHDRDrvr(cal, USERPROMPT, whichMeterType);
else
	cal = mglCalibrateMonDrvr(cal, USERPROMPT, whichMeterType);
end

%% Calibrate ambient
cal = mglCalibrateAmbDrvr(cal, 0, whichMeterType);

% Save the structure
fprintf(1, '\nSaving to %s.mat\n', newFileName);
SaveCalFile(cal, newFileName);

% Put up a plot of the essential data
figure(1); clf;
plot(SToWls(cal.S_device), cal.P_device);
xlabel('Wavelength (nm)', 'Fontweight', 'bold');
ylabel('Power', 'Fontweight', 'bold');
title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
axis([380, 780, -Inf, Inf]);

figure(2); clf;
plot(cal.rawdata.rawGammaInput, cal.rawdata.rawGammaTable, '+');
xlabel('Input value', 'Fontweight', 'bold');
ylabel('Normalized output', 'Fontweight', 'bold');
title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
hold on
plot(cal.gammaInput, cal.gammaTable);

hold off
figure(gcf);
drawnow;

% Close down meter
switch whichMeterType
    case 0
    case {1,4,5}
        CMClose(whichMeterType);
    case 2
        CVIClose;
    otherwise
        error('Invalid meter type');
end

% Let user know it's done
FlushEvents;
if (beepWhenDone == 1)
	fprintf('Calibration finished.  Hit a character exit.\n');
	ListenChar(2);
	while (1)
		Snd('Play',sin(0:10000));
		pause(2);
		if (CharAvail)
			break;
		end
	end
	GetChar;
	ListenChar(0);
elseif (beepWhenDone == 2)
	sendmail(emailToStr, 'Calibration Complete', 'It was done.  It was finished.  Yes, she thought, I have had my vision.');
end
