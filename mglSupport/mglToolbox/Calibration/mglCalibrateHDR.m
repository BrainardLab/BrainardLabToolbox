% mglCalibrateHDR
%
% Calling script for HDR monitor calibration.
%
% 2/12/10  dhb     Wrote as interface into mglGeneric routines
% 4/25/10   ar     Changed the basic and background measures requested for
%                  HDRBack so they are the same as those for HDRFront
% 5/20/10  dhb, ar Fix bug introduced with use of HDRGetMonitorIDs -- field cal.describe.HDRProjector
%                  is a flag, not a screen number. 
% 5/20/10  ar      Added functions that produce settings for the desired stimulus xyY and just collected calibration data
% 6/5/10   dhb     Extend range of yoked measurements, number of regular measurements.
% 6/11/10  dhb, ar Front calbirated with 2 dimensional linear model, add fit weight parameter for betacdf, optimized by hand.
 
%% Clear
clear; close all;

%% Which display to do basic calibration on?.
% Choices are:
%  'none'
%  'both'
%  'frontonly'
%  'backonly'
whichToDo = 'both';

%% Do post-calibration yoked measurements and adjustments
doYoked = 1;

%% Set meter type
% 0 - Fake meter, for debugging
% 1 - PR-650
whichMeterType = 0;

%% Gets the window IDs for the front and back screen.  This routine loads
% 'HDRDisplayInfo' found in PsychCalLocalData which contains known
% information about each screen, then tries to match that data against the
% list of active monitors currently attached to the computer to determine
% the MLG IDs of the front and back screens.
[frontScreenID, backScreenID] = HDRGetMonitorIDs;

%% Set parameters for LCD screen calibration and go
if (strcmp(whichToDo,'both') || strcmp(whichToDo,'frontonly'))
	cal = [];
	
	switch whichMeterType
		case {0,1}
			cal.describe.S = [380 4 101];
		case 2
			cal.describe.S = [380 1 401];
		otherwise
			cal.describe.S = [380 4 101];
	end
	cal.manual.use = 0;
	
	% Display specifices
	cal.describe.whichScreen = frontScreenID;
	cal.describe.whichBlankScreen = backScreenID;
	cal.describe.blankOtherScreen = 1;
	cal.describe.blankSettings = [0.5 0 0];
    cal.describe.blankFgSettings = [1 1 1]';
    cal.describe.whichMeterType = whichMeterType; 
    
	% Store the front and back screen IDs as determined by
	% HDRGetMonitorIDs.
	cal.describe.frontScreenID = frontScreenID;
	cal.describe.backScreenID = backScreenID;
	
	cal.bgColor = [190 190 190]'/255;
	cal.fgColor = [0.6 ; 0.6 ; 0.6]';
	
	cal.describe.meterDistance = 0.5;
	cal.describe.monitor = 'HDRFront';
	cal.describe.comment = 'HDR front (LCD) screen standard';
	newFileName = 'HDRFront';
    
    % This variable specifies whether we are doing some
    % special tricks to handle the HDR display, or not.
	cal.describe.HDRProjector = 0;
    
    % Make yoked measurements for later refitting of gamma?
    %   cal.describe.yokedmethod = 0 or not set, don't do it.
    %   cal.describe.yokedmethod = 1 - make measurements for R=G=B
    %   cal.describe.yokedmethod = 2 - make measurements at specified xy
    cal.describe.yokedmethod = 2;
    cal.describe.yoked_xy = [0.381 ; 0.385];
    %cal.describe.yoked_xy = [0.2518 ; 0.2919]';
    cal.describe.yoked_nTargets = 30;
    cal.describe.yoked_name = 'HDRFrontYoked';

	% Properties we think this monitor should have at
	% calibration time.
	desired.hz = 60;
	desired.screenSizePixel = [1280 1024];
	
	% Fitting parameters
	cal.describe.gamma.fitType = 'betacdf';
    cal.describe.gamma.useweight = 0.014;
	cal.describe.gamma.contrastThresh = 0.001;
	
	% Bits++?
	cal.usebitspp = 0;
	
	% Other parameters
    cal.describe.leaveRoomTime = 10;
	cal.describe.nAverage = 2;
	cal.describe.nMeas = 25;
    cal.describe.nLowEndCut = 0.15;
    cal.describe.nMeasLowEnd = 10;
	cal.describe.nMeasIfLow = cal.describe.nMeas - cal.describe.nMeasLowEnd +2; 
	cal.describe.boxSize = 200;
	cal.nDevices = 3;
	cal.nPrimaryBases = 2;
    if (strcmp(whichToDo,'frontonly'))
        beepWhenDone = 1; %#ok<*NASGU>
    else
        beepWhenDone = 0;
    end
	
	% Settings for measurements that allow a basic linearity check
	cal.basicmeas.settings = [ [1 1 1] ; [1 0 0] ; [0 1 0] ; [0 0 1] ; ...
		[0.75 0.75 0.75] ; [0.75 0 0] ; [0 0.75 0] ; [0 0 0.75] ; ...
		[0.5 0.5 0.5] ; [0.5 0 0] ; [0 0.5 0] ; [0 0 0.5] ; ...
		[0.25 0.25 0.25] ; [0.25 0 0] ; [0 0.25 0] ; [0 0 0.25] ; ...
		[0 0 0] ]';
    
    % Settings for measurements that allow a check of dependence on background
    cal.bgmeas.bgSettings = [ [1 1 1] ; [0 0 0] ]';
    cal.bgmeas.settings = [ [1 1 1] ; [0.5 0.5 0.5] ; [0 0 0] ]'; 
	
	% Call common driver to do the LCD calibration
	USERPROMPT = 1;
	cal.describe.promptforname = 1;
	mglCalibrateMonCommon;
	username = cal.describe.who;
end


%% Set parameters for projector calibration and go
if (strcmp(whichToDo,'both') || strcmp(whichToDo,'backonly'))
	
	cal = [];
	
	% Meter parameters
	switch whichMeterType
		case {0,1}
			cal.describe.S = [380 4 101];
		case 2
			cal.describe.S = [380 1 401];
		otherwise
			cal.describe.S = [380 4 101];
	end
	cal.manual.use = 0;
	
	% Display specifices
	cal.describe.whichScreen = backScreenID;
	cal.describe.whichBlankScreen = frontScreenID;
	cal.describe.blankOtherScreen = 1;
	cal.describe.blankSettings = [1 1 1];
    cal.describe.whichMeterType = whichMeterType;
	
	% Store the front and back screen IDs as determined by
	% HDRGetMonitorIDs.
	cal.describe.frontScreenID = frontScreenID;
	cal.describe.backScreenID = backScreenID;
	
	cal.bgColor = [190 190 190]'/255;
	cal.fgColor = [0.6 ; 0.6 ; 0.6]';
	
	cal.describe.meterDistance = 0.5;
	cal.describe.monitor = 'HDRBack';
	cal.describe.comment = 'HDR back (projector) screen standard';
	newFileName = 'HDRBack';
    
    % This variable specifies whether we are doing some
    % special tricks to handle the HDR display, or not.
	cal.describe.HDRProjector = 0;
    
    % Make yoked measurements for later refitting of gamma?
    %   cal.describe.yokedmethod = 0 or not set, don't do it.
    %   cal.describe.yokedmethod = 1 - make measurements for R=G=B
    %   cal.describe.yokedmethod = 2 - make measurements at specified xy
    cal.describe.yokedmethod = 2;
    cal.describe.yoked_xy = [0.381 ; 0.385];
    %cal.describe.yoked_xy = [0.2518 ; 0.2919]';
    cal.describe.yoked_nTargets = 30;
    cal.describe.yoked_name = 'HDRBackYoked';
	
	% Properties we think this monitor should have at
	% calibration time.
	desired.hz = 60;
	desired.screenSizePixel = [1280 1024];
	
	% Fitting parameters
	cal.describe.gamma.fitType = 'betacdf';
	cal.describe.gamma.contrastThresh = 0.001;
	
	% Bits++?
	cal.usebitspp = 0;
	
	% Other parameters
	cal.describe.leaveRoomTime = 10;
	cal.describe.nAverage = 2;
	cal.describe.nMeas = 25;
    cal.describe.nLowEndCut = 0.15;
    cal.describe.nMeasLowEnd = 10;
	cal.describe.nMeasIfLow = cal.describe.nMeas - cal.describe.nMeasLowEnd +2; 
	cal.describe.boxSize = 200;
	cal.nDevices = 3;
	cal.nPrimaryBases = 1;
	beepWhenDone = 0;
	
    % Settings for measurements that allow a basic linearity check
	cal.basicmeas.settings = [ [1 1 1] ; [1 0 0] ; [0 1 0] ; [0 0 1] ; ...
		[0.75 0.75 0.75] ; [0.75 0 0] ; [0 0.75 0] ; [0 0 0.75] ; ...
		[0.5 0.5 0.5] ; [0.5 0 0] ; [0 0.5 0] ; [0 0 0.5] ; ...
		[0.25 0.25 0.25] ; [0.25 0 0] ; [0 0.25 0] ; [0 0 0.25] ; ...
		[0 0 0] ]';
    
    % Settings for measurements that allow a check of dependence on background
    cal.bgmeas.bgSettings = [ [1 1 1] ; [0 0 0] ]';
    cal.bgmeas.settings = [ [1 1 1] ; [0.5 0.5 0.5] ; [0 0 0] ]'; 
    
	% Call common driver to do the LCD calibration
	if (strcmp(whichToDo,'backonly'))
		USERPROMPT = 1;
		cal.describe.promptforname = 1;
	else
		USERPROMPT = 0;
		cal.describe.promptforname = 0;
		cal.describe.who = username;
	end
	mglCalibrateMonCommon;
end

%% Make sure we don't confuse ourselves with left-over variables
clear cal

%% Do the yoked measurements for each calibration file
% Sometimes we want to make a special set of measurements that will
% be used to adjust the gamma functions in a manner that takes
% gun interactions into account.  A simple case of this occurs
% when we know that we will force the display to use settings
% R = G = B.  But a more general case is when we know the
% progression of the settings from a low luminance to a high
% luminance at, say, constant chromaticity.
if (doYoked)
	
	%If we are just taking yoked measurements, prompt user to focus meter,
	%otherwise don't
	if strcmp(whichToDo, 'none')
		USERPROMPT = 1;
	else
		USERPROMPT = 0;
	end
	
	% Reinitialize because serial port has been closed by mglCalibrateMonCommon
	switch whichMeterType
		case 0
		case 1
			CMCheckInit;
		case 2
			CVIOpen;
		otherwise
			error('Invalid meter type');
	end
	
	% Do both front and back
	theCals = {'front', 'back'};
	for whichCalIndex = 1:2
		whichCal = theCals{whichCalIndex};
		% Load the calibration file
		switch (whichCal)
			case 'front'
				cal = LoadCalFile('HDRFront');
			case 'back'
				cal = LoadCalFile('HDRBack');
			otherwise
				error('Illegal value for whichCal');
		end
		
		% Case where R=G=B
		if (isfield(cal.describe,'yokedmethod') && cal.describe.yokedmethod == 1)
			for i = 1:cal.nDevices
				cal.yoked.settings(i,:) = cal.rawdata.rawGammaInput';
				
			end
			cal = mglCalibrateYokedDrvr(cal, 0, whichMeterType);
			
			% Case where chromaticity is specified
		elseif (isfield(cal.describe,'yokedmethod') && cal.describe.yokedmethod == 2)
			if (~isfield(cal.describe,'yoked_xy'))
				error('Need to specify chromaticity for yoked == 2 option');
			end
			
			% Initialize HDRCal structure, based on measurements that we just made
			S = [380 4 101];
			load T_xyz1931
			T_xyz=683*SplineCmf(S_xyz1931, T_xyz1931, S);
			HDRCal.frontCal = LoadCalFile('HDRFront');
			HDRCal.backCal = LoadCalFile('HDRBack');
			method = 'backsqrteachrgb';
			HDRCal = InitializeHDRCalStructure(HDRCal,T_xyz,S,method);
			
			% Figure out front and back settings corresponding to our desired chromaticity series.
            % The reason we ask for settings out to twice the maximum is so that the settings for the
            % trailing gun will approach 1.0, ensuring that the yoked gamma is characterized with measurements
            % over the full input range for each gun.  Also note that the yoked settings are determined from
            % the unyoked calibration, so they will be a little different fron what is produced once the
            % yoked calibration file is set up.  But as long as the deviation isn't too big, this should be OK.
			[minLum,maxLum] = HDRFindMinMaxLumAtChrom(HDRCal,cal.describe.yoked_xy);
			cal.describe.yoked_minLum = 0;
			cal.describe.yoked_maxLum = 2*maxLum;
			[theTargetSensorxyY,theTargetSensorXYZ] = HDRFindTargetStimuliAtChrom(HDRCal,cal.describe.yoked_xy,cal.describe.yoked_nTargets, ...
				cal.describe.yoked_minLum,cal.describe.yoked_maxLum,1);
			[theBackRGB,theFrontRGB,theBackrgb,theFrontrgb] = HDRSensorToSettingsAcc(HDRCal, theTargetSensorXYZ);
			switch (whichCal)
				case 'front'
					cal.yoked.settings = [theFrontRGB [ 1 1 1]' ];
				case 'back'
					cal.yoked.settings = [theBackRGB [ 1 1 1]' ];
				otherwise
					error('Illegal value for field frontorback');
			end
			
			% Make the measurements
			cal = mglCalibrateYokedDrvr(cal, USERPROMPT, whichMeterType);
			
			% Ooops
		else
			error('You should not be trying to take yoked measurements if yokedmethod is not set.');
		end
		
		% Refit the gamma using the yoked measurements.  We set the yoked
		% field here so that CalibrateFitLinMod knows what to do.
		cal.nPrimaryBases = 1;
		cal = CalibrateFitLinMod(cal);
		cal = CalibrateFitYoked(cal);
		cal = CalibrateFitGamma(cal,2^cal.describe.dacsize);
		SaveCalFile(cal,cal.describe.yoked_name);
	end
	
	% Close down meter
	switch whichMeterType
		case 0
		case 1
			CMClose;
		case 2
			CVIClose;
		otherwise
			error('Invalid meter type');
	end
end






