function glwObj = GLW_InitCalibration(glwObj)

% If setting the calibration, the gamma must not have already been
% set explicity.  We check here just to make sure that we didn't screw up
% any error checking done in the GLWindow constructor.
if glwObj.private.gammaSpecified && ~isempty(glwObj.calibrationfile)
	error('Cannot set both the gamma and calibration files explicitly.');
end

% If the calibration was explicity set empty or defaulted to empty we don't
% process the gamma at all and assume the user knows what they're doing.
if isempty(glwObj.calibrationfile)
	glwObj.private.cal = [];
else
	switch glwObj.displaytype
		% HDR
		case glwObj.private.consts.displayTypes.hdr
			% Do nothing here (for now).
			glwObj.private.cal = [];
			
		% Bits++
		case glwObj.private.consts.displayTypes.bitspp
			% Load the calibration file, but don't bother with adjusting
			% the gamma.  It will be modified on the fly when objects are
			% added to the GLWindow.
			glwObj.private.cal = LoadCalFile(glwObj.calibrationfile);
			glwObj.private.cal = SetGammaMethod(glwObj.private.cal, ...
				glwObj.setgammamethodvalue);
			
		% Stereo and Stereo Bits++
		case {glwObj.private.consts.displayTypes.stereo, ...
				glwObj.private.consts.displayTypes.stereobitspp}
			% Run the gammas, which should be the identity if not
			% explicitly specified, through the calibration files.
			for i = 1:2
				cal = LoadCalFile(glwObj.calibrationfile{i});
				
				cal = SetGammaMethod(cal, glwObj.setgammamethodvalue);
				glwObj.gamma{i} = PrimaryToSettings(cal, glwObj.gamma{i}')';
			end
			
		% Regular, old, boring screen.
		case glwObj.private.consts.displayTypes.normal
			% Linearize the gamma.
			glwObj.private.cal = LoadCalFile(glwObj.calibrationfile);
			glwObj.private.cal = SetGammaMethod(glwObj.private.cal, ...
				glwObj.setgammamethodvalue);
			glwObj.gamma = PrimaryToSettings(glwObj.private.cal, ...
				glwObj.gamma')';
			
		otherwise
			error('Invalid display type "%s".', glwObj.displaytype);
	end
end
