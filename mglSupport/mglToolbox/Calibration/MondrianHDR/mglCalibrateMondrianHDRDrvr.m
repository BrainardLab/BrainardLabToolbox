function cal = mglCalibrateMondrianHDRDrvr(cal, USERPROMPT, whichMeterType)
% cal = mglCalibrateMondrianHDRDrvr(cal,USERPROMPT,whichMeterType)
%
% Main script for monitor calibration.  May be called
% once parameters are set up.
%
% Each monitor input channel is calibrated.
% A summary spectrum is computed.
% Gamma curves are computed.

% 11/25/09 dhb  Fix up foreground color operating point code.mglCalibrateMondrianHDRDrvr
% 11/29/09 dhb  No more g_usebitspp as global.  Passed instead.
%          dhb  Clean up unused variables, other warnings.
% 12/14/09 dhb  Use better way of setting identity clut
% 12/14/09 bjh  Added the hack around GLW_GetIdentityGamma to find the finicky renderer for the AChrom rig and adjust the
%               gamma table accordingly.  This should eventually be fixed to call some central routine.
% 1/21/10  dhb  Make a set of basic measurements that can be used to check linearity and to compare direct to predicted
%               measurements.
% 2/12/10  dhb  Pull out basic measurement settings into top level, to allow flexibility across what's being calibrated.]
% 2/12/10  dhb  Don't pass blankOtherScreen, now part of cal.describe structure.
%          dhb   Blanking now 'blanks' with passed settings.  And all entries of clut are set.
%          dhb  Don't pass usebitspp, now part of calibration structure.
% 2/14/10  dhb  Added, but didn't debug, measurements of effect of
% background on test.
%          dhb  Get rid of some stray mgl commands.
% 2/20/10  dhb  Put back the 'stray' commands,because they seem to matter.
% 4/25/10  dhb  Fix bug in call to mglMeasMonSpd for HDRProjector case 2.  Now it might work.
% 4/28/10  dhb, ar, mko  Properly save yoked data in the yoked measurement case.
% 5/25/10  dhb, ar       Remove passed HDRProjector arg to mglMeasMonSpd.
% 5/28/10  dhb           Blotto HDRProjector altogether.
% 6/5/10   dhb           Support more measurements at low end of gamma range
% 6/10/10  dhb           Fix goof in old definition of mGammaInputRaw introduced on 6/5.
% 7/12/10  cgb, ar Craeted new version of the calibration driver, in order to have a custom calibration in each condition.       

global GL;

% Define input settings for the measurements
if (isfield(cal.describe,'nMeasLowEnd'))
    mGammaInputRaw1 = linspace(0,cal.describe.nLowEndCut,cal.describe.nMeasLowEnd);
    mGammaInputRaw2 = linspace(cal.describe.nLowEndCut,1,cal.describe.nMeasIfLow);
    mGammaInputRaw = [mGammaInputRaw1(2:end) mGammaInputRaw2(2:end)]';
else
    mGammaInputRaw = linspace(0, 1, cal.describe.nMeas+1);
    mGammaInputRaw = mGammaInputRaw(2:cal.describe.nMeas+1)';
end


% User prompt
if USERPROMPT
	% Make sure that GetChar is actually listening for characters before we
	% call it.
	ListenChar(1);
	FlushEvents;
	
    if cal.describe.whichScreen == 1
        fprintf('Hit any key to proceed past this message and display a box.\n');
        fprintf('Focus radiometer on the displayed box.\n');
        fprintf('Once meter is set up, hit any key - you will get %g seconds\n',...
            cal.describe.leaveRoomTime);
        fprintf('to leave room.\n');
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
if ~isempty(strfind(cal.describe.monitor, 'HDRBack'))
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

% Measure some basic settings.  These may be compared to what happens when
% we predict the same values from the calibration itself.
fprintf('Basic check measurements, pass 1\n');
cal.basicmeas.spectra1 = mglMeasMondrianHDRSpd(cal.basicmeas.settings, cal, cal.describe.S, [], whichMeterType);

% Full specturm gamma curve measurements for each phosphor.  The obscure
% format used to store the data dates back to the days when MATLAB didn't
% support multi-dimensional matrices.
mon = zeros(cal.describe.S(3)*cal.describe.nMeas,cal.nDevices);
for a = 1:cal.describe.nAverage
    for i = 1:cal.nDevices
        fprintf('Monitor device %g\n',i);
        
        % Measure full gamma in random order
        mGammaInput = zeros(cal.nDevices, cal.describe.nMeas);
        mGammaInput(i,:) = mGammaInputRaw';
        sortVals = rand(cal.describe.nMeas,1);
        [nil, sortIndex] = sort(sortVals); %#ok<ASGLU>
        
        % Get indices for dark ambient
        darkIndex = setdiff(1:3,i);
        
        % Measure 
        useDark = zeros(3,1);
        useDark(darkIndex) = cal.fgColor(darkIndex);

        % Measure ambient
        darkAmbient1 = mglMeasMondrianHDRSpd(useDark, cal, cal.describe.S, 0, whichMeterType);

        mGammaInput(darkIndex(1),:) = ones(size(mGammaInputRaw'))*cal.fgColor(darkIndex(1));
        mGammaInput(darkIndex(2),:) = ones(size(mGammaInputRaw'))*cal.fgColor(darkIndex(2));
        [tempMon] = mglMeasMondrianHDRSpd(mGammaInput(:,sortIndex), cal, cal.describe.S, [], whichMeterType);
        tempMon(:, sortIndex) = tempMon;

        % Take another ambient reading and average
        darkAmbient2 = mglMeasMondrianHDRSpd(useDark, cal, cal.describe.S, 0, whichMeterType);
        darkAmbient = ((darkAmbient1+darkAmbient2)/2)*ones(1, cal.describe.nMeas);

        % Subtract ambient
        tempMon = tempMon - darkAmbient;
                        
        % Store data
        mon(:, i) = mon(:, i) + reshape(tempMon,cal.describe.S(3)*cal.describe.nMeas,1);
		
		% Store the data individually before averaging later.
		cal.rawdata.monSpd{a, i} = reshape(tempMon,cal.describe.S(3)*cal.describe.nMeas,1);
		cal.rawdata.monIndex{a, i} = sortIndex;
    end
end
mon = mon / cal.describe.nAverage;

% Measure the basic settings again.  This is to check for any drift over the course of the calibration
fprintf('Basic check measurements, pass 2\n');
cal.basicmeas.spectra2 = mglMeasMondrianHDRSpd(cal.basicmeas.settings, cal, cal.describe.S, [], whichMeterType);

% Measure the dependence of test on background values.
fprintf('Effect of background measurements\n');
calBG = cal;
for bg = 1:size(cal.bgmeas.bgSettings,2)
	% Poke the background color into every square of the Mondrian.
	for i = 1:size(calBG.mondrian.surroundColors, 1)
		for j = 1:size(calBG.mondrian.surroundColors, 2)
			calBG.mondrian.surroundColors(i,j,:) = cal.bgmeas.bgSettings(:,bg)';
		end
	end
	
    bgspectra = mglMeasMondrianHDRSpd(calBG.bgmeas.settings, calBG, calBG.describe.S, [], whichMeterType);
    cal.bgmeas.spectra{bg} = bgspectra;
end

% Close the screen.
mglClose;

% Report time
t1 = clock;
fprintf('CalibrateMonDrvr measurements took %g minutes\n', etime(t1, t0)/60);

% Pre-process data to get rid of negative values.
mon = EnforcePos(mon);
cal.rawdata.mon = mon;

% Use data to compute best spectra according to desired
% linear model.  We use SVD to find the best linear model,
% then scale to best approximate maximum
disp('Computing linear models');
cal = CalibrateFitLinMod(cal);

% Fit gamma functions.
cal.rawdata.rawGammaInput = mGammaInputRaw;
cal = CalibrateFitGamma(cal);

% Blank other screen
if cal.describe.blankOtherScreen
    mglSwitchDisplay(cal.describe.whichBlankScreen);
    mglClose;
end
