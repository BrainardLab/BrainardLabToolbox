% mglCalibrateMondrianHDR.m
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
% 6/11/10  dhb, ar Front calibrated with 2 dimensional linear model, add fit weight parameter for betacdf, optimized by hand.
% 7/11/10       ar Adjucted mglCalibrateHDRCode for the White condition of HDR Mondrian experiment (HDRAna) 
% 7/15/10       ar Takes more measurements: 15 lowMeas; nMeas = 40 (total) uses proper calibration files
% 7/17/10       ar The calibration routine now calls the function GenerateMondrianColorsCal when measuring yoked calibration settings.  
% 7/27/10       ar P_scatter is set to zero when yoked settings are measured and produced.   
% 1/11/10       ar switch to mglCalibrateYokedMondrianHDRDrvr, which sets the same background as in the experiment (HDRAna)
% 6/11/10       ar added an e-mail option to calibration. 
% 15/11/10      ar Made the change so that the background is drawn using the previous yoked calibration file (not standard). 

%% Clear
clear; close all;

% Make sure we've initialized Matlab OpenGL (MOGL).
InitializeMatlabOpenGL;

% Set the configuration file path.
exp.configFileDir = sprintf('%s/Calibration/MondrianHDR/config', GetToolboxDirectory('mglToolbox'));

% Read the condition list.
exp.conditionListFileName = sprintf('%s/conditions.cfg', exp.configFileDir);
exp.conditionList =  ReadStructsFromText(exp.conditionListFileName);
exp.numConditions = length(exp.conditionList);

% Display a list of what conditions are available and have the user select
% one by number.
while true
	fprintf('\n- Available conditions\n\n');
	
	for i = 1:exp.numConditions
		fprintf('%d - %s\n', i, exp.conditionList(i).name);
	end
	fprintf('\n');
	
	exp.conditionIndex = GetInput('Choose a condition number', 'number', 1);
	
	% If the user selected a condition in the range of available conditions,
	% break out of the loop.  Otherwise, display the condition list again.
	if any(exp.conditionIndex == 1:exp.numConditions)
		break;
	else
		disp('*** Invalid condition selected, try again.');
	end
end

% Set the config file name for this condition.
exp.configFileName = sprintf('%s/%s', exp.configFileDir, exp.conditionList(exp.conditionIndex).configFile);

% Load the config file and grab the experimental parateters.  These are
% shared with HDRAna and are required to generate the Mondrian colors.
cfgFile = ConfigFile(exp.configFileName);
params = convertToStruct(cfgFile);

% Generate the Mondrian colors based on the selected config file.
HDRCal.frontCal = LoadCalFile(sprintf('HDRFrontYokedMondrian%s', params.conditionName));
HDRCal.backCal = LoadCalFile(sprintf('HDRBackYokedMondrian%s', params.conditionName));
HDRCal.P_scatter = LoadCalFile(sprintf('P_scatter%s', params.conditionName));
params = GenerateMondrianColors(params, HDRCal);

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
whichMeterType = 1;

%% Gets the window IDs for the front and back screen.  This routine loads
% 'HDRDisplayInfo' found in PsychCalLocalData which contains known
% information about each screen, then tries to match that data against the
% list of active monitors currently attached to the computer to determine
% the MLG IDs of the front and back screens.
[frontScreenID, backScreenID] = HDRGetMonitorIDs;
try
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
	
	% Display specifics
	cal.describe.variation = 'MondrianHDR';
	cal.describe.whichScreen = frontScreenID;
	cal.describe.whichBlankScreen = backScreenID;
	cal.describe.blankOtherScreen = 1;
	cal.describe.blankSettings = [1 1 1];
    cal.describe.whichMeterType = whichMeterType; 
	cal.describe.screenDims = [38.1 30.48];
    
	% Store the front and back screen IDs as determined by
	% HDRGetMonitorIDs.
	cal.describe.frontScreenID = frontScreenID;
	cal.describe.backScreenID = backScreenID;
	
	cal.bgColor = [0 0 0];
	
	% Selected Mondrian condition, e.g. white, full, etc.
	cal.mondrian.condition = params.conditionName;
	
	% Store the generated Mondrian colors.
	cal.mondrian.surroundColors = params.frontRGBHDR;
	
	% Store the Mondrian info.
	cal.mondrian.edgeSize = params.edgeSize;
	
    % This means to what level are all the two other colors set to in
	% yoked measurments
    
    cal.fgColor = [0.6 ; 0.6 ; 0.6]';
	
	cal.describe.meterDistance = 0.75;
	cal.describe.monitor = 'HDRFront';
	cal.describe.comment = 'HDR front (LCD) screen standard';
	newFileName = sprintf('HDRFrontMondrian%s', cal.mondrian.condition);
    
    % This variable specifies whether we are doing some
    % special tricks to handle the HDR display, or not.
	cal.describe.HDRProjector = 0;
    
    % Make yoked measurements for later refitting of gamma?
    %   cal.describe.yokedmethod = 0 or not set, don't do it.
    %   cal.describe.yokedmethod = 1 - make measurements for R=G=B
    %   cal.describe.yokedmethod = 2 - make measurements at specified xy
    cal.describe.yokedmethod = 2;
    cal.describe.yoked_xy = [params.target_x ; params.target_y];
    cal.describe.yoked_nTargets = params.nTargets;
    cal.describe.yoked_name = sprintf('HDRFrontYokedMondrian%s', cal.mondrian.condition);

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
	cal.describe.nMeas = 40;
    cal.describe.nLowEndCut = 0.15;
    cal.describe.nMeasLowEnd = 15;
	cal.describe.nMeasIfLow = cal.describe.nMeas - cal.describe.nMeasLowEnd +2; 
	cal.describe.boxSize = 175;
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
	
	% Display specifics.
	cal.describe.variation = 'MondrianHDR';
	cal.describe.whichScreen = backScreenID;
	cal.describe.whichBlankScreen = frontScreenID;
	cal.describe.blankOtherScreen = 1;
	cal.describe.blankSettings = [1 1 1];
    cal.describe.whichMeterType = whichMeterType;
	cal.describe.screenDims = [38.1 30.48];
	
	% Store the front and back screen IDs as determined by
	% HDRGetMonitorIDs.
	cal.describe.frontScreenID = frontScreenID;
	cal.describe.backScreenID = backScreenID;
	
	cal.bgColor = [0 0 0];
	
	% Selected Mondrian condition, e.g. white, full, etc.
	cal.mondrian.condition = params.conditionName;
	
	% Store the generated Mondrian colors.     
    cal.mondrian.surroundColors = params.backRGBHDR;
	
	% Store the Mondrian info.
	cal.mondrian.edgeSize = params.edgeSize;
	
    % This means to what level are all the two other colors set to in
	% yoked measurments
    
    cal.fgColor = [0.6 ; 0.6 ; 0.6]';
	
	cal.describe.meterDistance = 0.75;
	cal.describe.monitor = 'HDRBack';
	cal.describe.comment = 'HDR back (projector) screen standard';
	newFileName = sprintf('HDRBackMondrian%s', cal.mondrian.condition);
    
    % This variable specifies whether we are doing some
    % special tricks to handle the HDR display, or not.
	cal.describe.HDRProjector = 0;
    
    % Make yoked measurements for later refitting of gamma?
    %   cal.describe.yokedmethod = 0 or not set, don't do it.
    %   cal.describe.yokedmethod = 1 - make measurements for R=G=B
    %   cal.describe.yokedmethod = 2 - make measurements at specified xy
    cal.describe.yokedmethod = 2;
    cal.describe.yoked_xy = [params.target_x ; params.target_y];
    cal.describe.yoked_nTargets = params.nTargets;
    cal.describe.yoked_name = sprintf('HDRBackYokedMondrian%s', cal.mondrian.condition);
	
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
	cal.describe.nMeas = 40;
    cal.describe.nLowEndCut = 0.15;
    cal.describe.nMeasLowEnd = 15;
	cal.describe.nMeasIfLow = cal.describe.nMeas - cal.describe.nMeasLowEnd +2; 
	cal.describe.boxSize = 175;
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
	
	HDRCal.frontCal = LoadCalFile(sprintf('HDRFrontMondrian%s', params.conditionName));
	HDRCal.backCal = LoadCalFile(sprintf('HDRBackMondrian%s', params.conditionName));
	HDRCal.P_scatter = zeros(HDRCal.frontCal.S_device(3),1);
    
	% Do both front and back
	theCals = {'front', 'back'};
	for whichCalIndex = 1:2
		whichCal = theCals{whichCalIndex};
		% Load the calibration file
		switch (whichCal)
			case 'front'
				cal = LoadCalFile(sprintf('HDRFrontMondrian%s', params.conditionName));
			case 'back'
				cal = LoadCalFile(sprintf('HDRBackMondrian%s', params.conditionName));
			otherwise
				error('Illegal value for whichCal');
		end
		
		% Case where R=G=B
		if (isfield(cal.describe,'yokedmethod') && cal.describe.yokedmethod == 1)
			for i = 1:cal.nDevices
				cal.yoked.settings(i,:) = cal.rawdata.rawGammaInput';
				
			end
			cal = mglCalibrateYokedMondrianHDRDrvr(cal, 0, whichMeterType);
			
			% Case where chromaticity is specified
		elseif (isfield(cal.describe,'yokedmethod') && cal.describe.yokedmethod == 2)
			if (~isfield(cal.describe,'yoked_xy'))
				error('Need to specify chromaticity for yoked == 2 option');
			end
			
			% Regenerate the Mondrian colors based on the previous
			% calibration.
			params.luminanceHeadroom = 1;
			params = GenerateMondrianColorsCal(params, HDRCal);
			
			switch (whichCal)
				case 'front'
					cal.yoked.settings = [params.theFrontRGB [ 1 1 1]' ];
					cal.mondrian.surroundColors = params.frontRGBHDR;
				case 'back'
					cal.yoked.settings = [params.theBackRGB [ 1 1 1]' ];
					cal.mondrian.surroundColors = params.backRGBHDR;
				otherwise
					error('Illegal value for field frontorback');
			end
			
			% Make the measurements
			cal = mglCalibrateYokedMondrianHDRDrvr(cal, 0, whichMeterType);
			
			% Ooops
		else
			error('You should not be trying to take yoked measurements if yokedmethod is not set.');
		end
		
		% Refit the gamma using the yoked measurements.  We set the yoked
		% field here so that CalibrateFitLinMod knows what to do.
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
	
	% Send an e-mail to Ana.
	setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
	setpref('Internet', 'E_Mail', 'radonjic@sas.upenn.edu');
	sendmail('radonjic@sas.upenn.edu', 'HDR Calibration Complete', 'I am done.');
	
	mglSwitchDisplay(-1);
catch e
	% Send an e-mail to Ana showing the error.
	setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
	setpref('Internet', 'E_Mail', 'radonjic@sas.upenn.edu');
	sendmail('radonjic@sas.upenn.edu', 'HDR Calibration Error', e.message);
	
	mglSwitchDisplay(-1);
	
	rethrow(e);
end
