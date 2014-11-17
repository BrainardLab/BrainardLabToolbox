function cal = mglCalibrateYokedMondrianHDRDrvr(cal,USERPROMPT,whichMeterType)
% cal = mglCalibrateYokedMondrianHDRDrvr(cal,USERPROMPT,whichMeterType)
%
% Make the ex-post yoked measurements for gamma adjustment.
%
% 5/25/10   dhb, ar     Wrote from mglCalibrateAmbDrvr.

global GL;

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

% Blank other screen
if cal.describe.blankOtherScreen
    mglSwitchDisplay(cal.describe.whichBlankScreen);
	mglOpen(cal.describe.whichBlankScreen);
	mglSetGammaTable([1 1 1]' * linspace(0, 1, 256));
	mglClearScreen([1 1 1]);
	mglFlush;
	
	% Make sure the cursor is displayed.
	mglDisplayCursor;
end

% Blank screen to be measured
mglSwitchDisplay(cal.describe.whichScreen);
mglOpen(cal.describe.whichScreen);
mglSetGammaTable([1 1 1]' * linspace(0, 1, 256));
mglClearScreen(cal.bgColor);
mglFlush;

% Make sure the cursor is displayed.
mglDisplayCursor;

% Only warp the back screen, no need for the front.
if strcmp(cal.describe.monitor, 'HDRBack')
	% Load the warp data which creates the 'warpParams' variable.
	fprintf('- Loading warp data...');
	warpCal = LoadCalFile('HDRWarp');
	fprintf('Done\n');
	
	% Setup the framebuffer object.
	fprintf('- Creating framebuffer object...');
	mglSwitchDisplay(cal.describe.whichScreen);
	%cal.mondrian.fbSize = warpCal.warpParams.fbSize;
	if isfield(warpCal.warpParams, 'fbSize')
		cal.mondrian.fbSize = warpCal.warpParams.fbSize;
	else
		cal.mondrian.fbSize = [warpCal.warpParams.fbObject.width, warpCal.warpParams.fbObject.height];
	end
	
	[cal.mondrian.fbObject, cal.mondrian.fbTexture] = mglInitFrameBuffer(cal.mondrian.fbSize);
	fprintf('Done\n');
	
	% This lets us know what kind of framebuffer object we made since we must
	% texture map it later.
	if cal.mondrian.fbSize(1) == cal.mondrian.fbSize(2)
		cal.mondrian.texType = GL.TEXTURE_2D;
	else
		cal.mondrian.texType = GL.TEXTURE_RECTANGLE_ARB;
	end
	
	% Create the screen warp display list.
	fprintf('- Pre-creating warp vertices...');
	if cal.mondrian.texType == GL.TEXTURE_2D
		cal.mondrian.warpList = HDRCreateWarpList(warpCal.warpParams.actualGrid, [1 1]);
	else
		cal.mondrian.warpList = HDRCreateWarpList(warpCal.warpParams.actualGrid, cal.mondrian.fbSize);
	end
	fprintf('Done\n');
end

% Create the Mondrian vertices.
cal.mondrian.mondrianVerts = GenerateMondrianVertices(cal.mondrian.edgeSize);

% Draw a the initial Mondrian to measure and line up the radiometer with.
DrawMondrianHDRStimulus(cal, [1 1 1]);

% Wait for user
if USERPROMPT == 1
    FlushEvents;
    GetChar;
	fprintf('Pausing for %d seconds ...', cal.describe.leaveRoomTime);
	WaitSecs(cal.describe.leaveRoomTime);
	fprintf(' done\n');
end

% Start timing
t0 = clock;

fprintf('Measuring yoked settings\n');
cal.yoked.spectra = mglMeasMondrianHDRSpd(cal.yoked.settings, cal, cal.describe.S, [], whichMeterType);
offSpd =  mglMeasMondrianHDRSpd(zeros(cal.nDevices,1), cal, cal.describe.S, 0, whichMeterType);
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
