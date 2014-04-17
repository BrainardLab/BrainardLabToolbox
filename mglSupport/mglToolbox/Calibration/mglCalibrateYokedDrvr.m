function cal = mglCalibrateYokedDrvr(cal,USERPROMPT,whichMeterType)
% cal = mglCalibrateYokedDrvr(cal,USERPROMPT,whichMeterType)
%
% Make the ex-post yoked measurements for gamma adjustment.
%
% 5/25/10   dhb, ar     Wrote from mglCalibrateAmbDrvr.
% 11/05/10 dhb, kmo      Add feature to allow writing a test box on the back screen.  The alignment code is not in place in this program,
%                        so the alignment may be a bit crude.

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
	
	 % If foreground settings for the blanked display have been set,
    % then draw a box of the test size into the frame buffer and
    % set it to the specified settings.
    if (isfield(cal.describe,'blankFgSettings'))
        % Draw a box to measure at
        blankClut(2,:) = cal.describe.blankFgSettings';
        mglFillRect(MGL.screenWidth/2, MGL.screenHeight/2, [cal.describe.boxSize cal.describe.boxSize], ...
            [1/255 1/255 1/255]);
        if cal.usebitspp
            mglBitsPlusSetClut(blankClut);
        else
            mglFlush;
            mglSetGammaTable(blankClut');
        end
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

% Draw the measurement box
theClut(2,:) = [1 1 1];
mglFillRect(MGL.screenWidth/2, MGL.screenHeight/2, [cal.describe.boxSize cal.describe.boxSize], ...
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
    mglFillRect(MGL.screenWidth/2, MGL.screenHeight/2, [cal.describe.boxSize cal.describe.boxSize], ...
        [1/255 1/255 1/255]);
    mglBitsPlusSetClut(theClut);
else
	mglSetGammaTable(theClut');
end

% Start timing
t0 = clock;

% Draw the rectangle on the screen.
mglFillRect(MGL.screenWidth/2, MGL.screenHeight/2, [cal.describe.boxSize cal.describe.boxSize], ...
    [1/255 1/255 1/255]);

% If we're using Bits++, swap buffers.
if cal.usebitspp
    mglFlush;
end

fprintf('Measuring yoked settings\n');
cal.yoked.spectra = mglMeasMonSpd(cal.yoked.settings, cal.describe.S, [], whichMeterType, cal.usebitspp, theClut);
offSpd =  mglMeasMonSpd(zeros(cal.nDevices,1), cal.describe.S, 0, whichMeterType, cal.usebitspp, theClut);
cal.yoked.spectra = cal.yoked.spectra - offSpd(:,ones(1,size(cal.yoked.spectra,2)));

% Close the screen
mglClose;

% Report time
t1 = clock;
fprintf('CalibrateYokedDrvr measurements took %g minutes\n', etime(t1,t0)/60);

% Blank other screen
if cal.describe.blankOtherScreen
	mglSwitchDisplay(cal.describe.whichBlankScreen);
	mglClose;
end

