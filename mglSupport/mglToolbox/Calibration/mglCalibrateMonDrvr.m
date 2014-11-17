function cal = mglCalibrateMonDrvr(cal, USERPROMPT, whichMeterType)
% cal = mglCalibrateMonDrvr(cal,USERPROMPT,whichMeterType)
%
% Main script for monitor calibration.  May be called
% once parameters are set up.
%
% Each monitor input channel is calibrated.
% A summary spectrum is computed.
% Gamma curves are computed.
%
% 11/25/09 dhb  Fix up foreground color operating point code.
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
% 4/28/10  dhb, ar, kmo  Properly save yoked data in the yoked measurement case.
% 5/25/10  dhb, ar       Remove passed HDRProjector arg to mglMeasMonSpd.
% 5/28/10  dhb           Blotto HDRProjector altogether.
% 6/5/10   dhb           Support more measurements at low end of gamma range
% 6/10/10  dhb           Fix goof in old definition of mGammaInputRaw introduced on 6/5.
% 7/02/10  ar, cgb       Added code to store each calibration data set individually in addition to the averaged data (cal.rawdata.monSpd)
% 11/05/10 dhb, kmo      Add feature to allow writing a test box on the back screen.  The alignment code is not in place in this program,
%                        so the alignment may be a bit crude.
% 3/8/11   dhb, mm       Put in code to calibrate back projector with r=g=b.
%                        Conditional on basicmeas, bgmeas fields -> don't do if not specified.
%                        Make size of nMeas based on size of mGammaInputRaw, rather than passed cal.describe.nMeas.
%                        Did this to try to handle special case of nMeas < nMeasLowEnd
% 6/22/11   dhb, tyl     Handle boxOffsetX and Y.
% 10/20/11 tyl, cgb      Added a reassignment of the global variable MGL
%                        because MATLAB clears it for some reason

global MGL;

% Define input settings for the measurements
if (isfield(cal.describe,'nMeasLowEnd'))
    mGammaInputRaw1 = linspace(0,cal.describe.nLowEndCut,cal.describe.nMeasLowEnd);
    mGammaInputRaw2 = linspace(cal.describe.nLowEndCut,1,cal.describe.nMeasIfLow);
    mGammaInputRaw = [mGammaInputRaw1(2:end) mGammaInputRaw2(2:end)]';
else
    mGammaInputRaw = linspace(0, 1, cal.describe.nMeas+1);
    mGammaInputRaw = mGammaInputRaw(2:cal.describe.nMeas+1)';
end
nMeasReally = length(mGammaInputRaw);

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


%  Get identity clut if bitspp
if cal.usebitspp
    % Gets the OpenGL info on this machine.
    openGLData = opengl('data');
    
    % Look to see what video card we're using, and choose the identity gamma
    % accordingly.  Fix this someday to call a central routine
    switch openGLData.Renderer
        case 'NVIDIA GeForce GT 120 OpenGL Engine'
            identityGamma = linspace(0, 1023/1024, 256)' * [1 1 1];
            
        otherwise
            identityGamma = linspace(0, 1, 256)' * [1 1 1];
    end
end

% Blank other screen.  Note that despite the name, this can
% be used in setups like the HDR display to control the non-calibrated
% display.  An example of opportunistic evolution -- the feature was
% initally added to automatically blank the console display (where the
% program is running), but it provided an easy path to handle another
% display when needed.
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
        mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
            [1/255 1/255 1/255]);
        if cal.usebitspp
            mglBitsPlusSetClut(blankClut);
        else
            mglFlush;
            mglSetGammaTable(blankClut');
        end
    end
	
	% Make sure the cursor is displayed.
	mglDisplayCursor;
end

% Blank screen to be measured
mglSwitchDisplay(cal.describe.whichScreen);
mglOpen(cal.describe.whichScreen);
mglScreenCoordinates;
theClut = zeros(256, 3);
if cal.usebitspp
    mglSetGammaTable(identityGamma');
    mglBitsPlusSetClut(theClut);
else
    mglSetGammaTable(theClut');
end

% Make sure the cursor is displayed.
mglDisplayCursor;

% Reassign global variable to account for MATLAB clearing it mysteriously. 
global MGL

% Draw a box to measure at
theClut(2,:) = [1 1 1];
mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
    [1/255 1/255 1/255]);
if cal.usebitspp
    mglBitsPlusSetClut(theClut);
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

% Measure some basic settings.  These may be compared to what happens when
% we predict the same values from the calibration itself.
if (isfield(cal,'basicmeas'))
	fprintf('Basic check measurements, pass 1\n');
	cal.basicmeas.spectra1 = mglMeasMonSpd(cal.basicmeas.settings, cal.describe.S, [], whichMeterType, cal.usebitspp, theClut);
end

% Full specturm gamma curve measurements for each phosphor.  The obscure
% format used to store the data dates back to the days when MATLAB didn't
% support multi-dimensional matrices.
mon = zeros(cal.describe.S(3)*nMeasReally,cal.nDevices);
for a = 1:cal.describe.nAverage
    for i = 1:cal.nDevices
        fprintf('Monitor device %g\n',i);
        
        % Measure full gamma in random order
        mGammaInput = zeros(cal.nDevices, nMeasReally);
        mGammaInput(i,:) = mGammaInputRaw';
        sortVals = rand(nMeasReally,1);
        [nil, sortIndex] = sort(sortVals); %#ok<ASGLU>
        
        % Get indices for dark ambient
        darkIndex = setdiff(1:3,i);
        
        % Measure 
        useDark = zeros(3,1);
        useDark(darkIndex) = cal.fgColor(darkIndex);

        % Measure ambient
        fprintf('\tDark measurements 1\n');
        darkAmbient1 = mglMeasMonSpd(useDark, cal.describe.S, 0, whichMeterType, cal.usebitspp, theClut);

        fprintf('\tDevice measurements\n');
        mGammaInput(darkIndex(1),:) = ones(size(mGammaInputRaw'))*cal.fgColor(darkIndex(1));
        mGammaInput(darkIndex(2),:) = ones(size(mGammaInputRaw'))*cal.fgColor(darkIndex(2));
		
		% Handle the annoying ver special case where we calibrate in
		% monocrome mode for the stereo HDR projector.  This, with luck,
		% will all get handled more gracefully when we move to our object
		% oriented calibration scheme sometime in the future.
		%
		% This only does the measurements for one nomimal channel (R).  The
		% G and B are dummy data.
		if (isfield(cal.describe,'HDRProjector') && strcmp(cal.describe.HDRProjector,'r=g=b'))
			useMeasHack = zeros(3,1);
			for k = 1:nMeasReally
				if (i == 1)
					useMeasHack(:) = mGammaInput(i,k);
					tempMon(:,k) = mglMeasMonSpd(useMeasHack,cal.describe.S,'off', whichMeterType, cal.usebitspp, theClut);
				else
					tempMon(i,:) = tempMon(1,:);
				end
			end
		else
			[tempMon] = mglMeasMonSpd(mGammaInput(:,sortIndex), ...
				cal.describe.S, [], whichMeterType, cal.usebitspp,theClut);
			tempMon(:, sortIndex) = tempMon;
		end

        % Take another ambient reading and average
        fprintf('\tDark measurements 2\n');
        darkAmbient2 = mglMeasMonSpd(useDark, cal.describe.S, 0, whichMeterType, cal.usebitspp, theClut);
        darkAmbient = ((darkAmbient1+darkAmbient2)/2)*ones(1, nMeasReally);

        % Subtract ambient
        tempMon = tempMon - darkAmbient;
                        
        % Store data
        mon(:, i) = mon(:, i) + reshape(tempMon,cal.describe.S(3)*nMeasReally,1);
		
		% Store the data individually before averaging later.
		cal.rawdata.monSpd{a, i} = reshape(tempMon,cal.describe.S(3)*nMeasReally,1);
		cal.rawdata.monIndex{a, i} = sortIndex;
    end
end
mon = mon / cal.describe.nAverage;

% Measure the basic settings again.  This is to check for any drift over the course of the calibration
if (isfield(cal,'basicmeas'))
	fprintf('Basic check measurements, pass 2\n');
	cal.basicmeas.spectra2 = mglMeasMonSpd(cal.basicmeas.settings, cal.describe.S, [], whichMeterType, cal.usebitspp, theClut);
end

% Measure the dependence of test on background values.
if (isfield(cal,'bgmeas'))
	fprintf('Effect of background measurements\n');
	for bg = 1:size(cal.bgmeas.bgSettings,2)
		theClut(1,:) = cal.bgmeas.bgSettings(:,bg)';
		if cal.usebitspp
			mglFillRect(MGL.screenWidth/2+cal.describe.boxOffsetX, MGL.screenHeight/2+cal.describe.boxOffsetY, [cal.describe.boxSize cal.describe.boxSize], ...
				[1/255 1/255 1/255]);
			mglBitsPlusSetClut(theClut);
		else
			mglSetGammaTable(theClut');
		end
		bgspectra = mglMeasMonSpd(cal.bgmeas.settings, cal.describe.S, [], whichMeterType, cal.usebitspp, theClut);
		cal.bgmeas.spectra{bg} = bgspectra;
	end
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
