function calibrationFiles = getCalibrationFiles(glwObj)
% calibrationFiles = getCalibrationFiles(glwObj)
%
% Description:
% Gets the calibration files attached to the GLWindow object.
%
% Input:
% glwObj (GLWindow) - The GLWindow object.
%
% Output:
% calibrationFiles (cell array | empty) - Cell array of the calibration
%   files used.  Empty if no calibration file is associated with the
%   GLWindow object.

if nargin ~= 1
	error('Usage: calibrationFiles = getCalibrationFiles(glwObj)');
end

calibrationFiles = {};

switch glwObj.displaytype
	% HDR
	case glwObj.private.consts.displayTypes.hdr
		[backCal, frontCal] = initHDRCalFiles;
		
		calibrationFiles{1} = frontCal;
		calibrationFiles{2} = backCal;
		
	% Bits++
	case glwObj.private.consts.displayTypes.bitspp
		% Load the calibration file, but don't bother with adjusting
		% the gamma.  It will be modified on the fly when objects are
		% added to the GLWindow.
		glwObj.private.cal = LoadCalFile(glwObj.calibrationfile);
		glwObj.private.cal = SetGammaMethod(glwObj.private.cal, ...
			glwObj.setgammamethodvalue);
		
		if ~isempty(glwObj.private.cal)
			calibrationFiles = {glwObj.private.cal};
		end
		
	% Stereo and Stereo Bits++
	case {glwObj.private.consts.displayTypes.stereo, ...
			glwObj.private.consts.displayTypes.stereobitspp}
		
		% Calibration files.
		for i = 1:2
			cal = LoadCalFile(glwObj.calibrationfile{i});
			calibrationFiles{i} = SetGammaMethod(cal, glwObj.setgammamethodvalue); %#ok<AGROW>
		end
		
		% Add on the warp files, too.
		
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
