function cal = mglCalibrateAmbDrvr(cal,USERPROMPT,whichMeterType)
% cal =  mglCalibrateAmbDrvr(cal,USERPROMPT,whichMeterType)
%
% This script does the work for monitor ambient calibration.

% 4/4/94		dhb		Wrote it.
% 8/5/94		dhb, ccc	More flexible interface.
% 9/4/94		dhb		Small changes.
% 10/20/94	dhb		Add bgColor variable.
% 12/9/94   ccc   Nine-bit modification
% 1/23/95		dhb		Pulled out working code to be called from elsewhere.
%						dhb		Make user prompting optional.
% 1/24/95		dhb		Get filename right.
% 12/17/96  dhb, jmk  Remove big bug.  Ambient wasn't getting set.
% 4/12/97   dhb   Update for new toolbox.
% 8/21/97		dhb		Don't save files here.
%									Always measure.
% 4/7/99    dhb   NINEBIT -> NBITS
%           dhb   Handle noMeterAvail, RADIUS switches.
% 9/22/99   dhb, mdr  Make boxRect depend on boxSize, defined up one level.
% 12/2/99   dhb   Put background on after white box for aiming.
% 8/14/00   dhb   Call to CMETER('Frequency') only for OS9.
% 8/20/00   dhb   Remove bits arg to SetColor.
% 8/21/00   dhb   Remove RADIUS arg to MeasMonSpd.
% 9/11/00   dhb   Remove syncMode code, any direct refs to CMETER.
% 9/14/00   dhb   Use OpenWindow to open.
%           dhb   Made it a function.
% 7/9/02    dhb   Get rid of OpenWindow, CloseWindow.
% 9/23/02   dhb, jmh  Force background to zero when measurements come on.
% 2/26/03   dhb   Tidy comments.
% 4/1/03    dhb   Fix ambient averaging.
% 11/29/09  dhb   No more g_usebitspp as global.  Passed instead.
%           dhb   Clean up warnings.
% 12/14/09  bjh   Added the hack around GLW_GetIdentityGamma to find the finicky renderer for the AChrom rig and adjust the
%                 gamma table accordingly.
% 2/12/10   dhb   Don't pass blankOtherScreen, now part of cal.describe structure.
%           dhb   Blanking now 'blanks' with passed settings.  And all entries of clut are set.
%           dhb   Don't pass usebitspp, now part of calibration structure.
%           dhb   Remove CMCheckInit.  This is done in calling program.
%           dhb   Remove call to Screen('Close',window), which opened the 'Window design and analysis tool'
%           dhb   Get rid of some stray mgl commands.
% 2/20/10   dhb   Put the 'stray' stuff back in, fix bg settings.
% 6/22/11   dhb, tyl Handle boxOffsetX and Y.

global MGL;

% User prompt
if USERPROMPT
	if cal.describe.whichScreen == 1
		fprintf('Hit any key to proceed past this message and display a box.\n');
		fprintf('Focus radiometer on the displayed box.\n');
		fprintf('Once meter is set up, hit any key - you will get %g seconds\n',...
                cal.describe.leaveRoomTime);
		fprintf('to leave room.\n');
        FlushEvents;
		GetChar;
	else
		fprintf('Focus radiometer on the displayed box.\n');
		fprintf('Once meter is set up, hit any key - you will get %g seconds\n',...
                cal.describe.leaveRoomTime);
		fprintf('to leave room.\n');
	end
end

% Get proper identity clut for this hardware.
if cal.usebitspp
    % Gets the OpenGL info on this machine.
    openGLData = opengl('data');
    
    % Look to see what video card we're using, and choose the identity gamma
    % accordingly.
    switch openGLData.Renderer
        case 'NVIDIA GeForce GT 120 OpenGL Engine'
            identityGamma = linspace(0, 1023/1024, 256)' * [1 1 1];
            
        otherwise
            identityGamma = linspace(0, 1, 256)' * [1 1 1];
    end
end

% Blank other screen
if cal.describe.blankOtherScreen
	mglSwitchDisplay(cal.describe.whichBlankScreen);
	mglOpen(cal.describe.whichBlankScreen);
	mglScreenCoordinates;
    blankClut = ones(256,1)*cal.describe.blankSettings;
    if cal.usebitspp
        mglSetGammaTable(identityGamma');
        mglBitsPlusSetClut(blankClut);
	else
		mglSetGammaTable(blankClut);
    end
end

% Blank screen to be measured
mglSwitchDisplay(cal.describe.whichScreen);
mglOpen(cal.describe.whichScreen);
mglScreenCoordinates;
theClut = zeros(256,3);
if cal.usebitspp
	mglSetGammaTable(identityGamma');
    mglBitsPlusSetClut(theClut);
else
    mglSetGammaTable(theClut');
end

% If for some reason the mglSwitchDisplay call screwed up our MGL global,
% re-initialized it.
if ~exist('MGL', 'var')
	global MGL; %#ok<REDEF,TLEV>
end

% Draw the measurement box
theClut(2,:) = [1 1 1];
mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
	[1/255 1/255 1/255]);
if cal.usebitspp
    mglBitsPlusSetClut(theClut .* (2^16 - 1));
else
	mglFlush;
	mglSetGammaTable(theClut');
end

% Wait for user
if USERPROMPT == 1
    FlushEvents;
    GetChar;
	fprintf('Pausing for %d seconds ...', cal.describe.leaveRoomTime);
	WaitSecs(cal.describe.leaveRoomTime);
	fprintf(' done\n');
end

% Put correct surround for measurements.
theClut(1,:) = cal.bgColor';
if cal.usebitspp
    mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
        [1/255 1/255 1/255]);
    mglBitsPlusSetClut(theClut);
else
	mglSetGammaTable(theClut');
end

% Start timing
t0 = clock;

% Draw the rectangle on the screen.
mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
    [1/255 1/255 1/255]);

% If we're using Bits++, swap buffers.
if cal.usebitspp
    mglFlush;
end

fprintf('Measuring ambient light\n');
ambient = zeros(cal.describe.S(3), 1);
for a = 1:cal.describe.nAverage
    % Measure ambient
    ambient = ambient + mglMeasMonSpd([0 0 0]', cal.describe.S, 0, whichMeterType, cal.usebitspp, theClut);
end
ambient = ambient / cal.describe.nAverage;

% Close the screen
mglClose;

% Report time
t1 = clock;
fprintf('CalibrateAmbDrvr measurements took %g minutes\n', etime(t1,t0)/60);

% Update structure
Smon = cal.describe.S;
Tmon = WlsToT(Smon);
cal.P_ambient = ambient;
cal.T_ambient = Tmon;
cal.S_ambient = Smon;

% Blank other screen
if cal.describe.blankOtherScreen
	mglSwitchDisplay(cal.describe.whichBlankScreen);
	mglClose;
end

