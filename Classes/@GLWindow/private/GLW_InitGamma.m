function glwObj = GLW_InitGamma(glwObj)
% glwObj = GLW_InitGamma(glwObj)
%
% Description:
% Initializes the gamma for the GLWindow constructor.  It mainly sets up a
% default gamma (usually the identity) if one wasn't specified.
%
% Input:
% glwObj (GLWindow) - GLWindow object.
%
% Output:
% glwObj (GLWindow) - Updated GLWindow object.

% Make sure we didn't screw up and allow the gamma to be explicitly set if
% the calibration files were specified.
if glwObj.private.calibrationFileSpecified && ~isempty(glwObj.gamma)
	error('Cannot set both the gamma and calibration files explicitly.');
end

% Set the gamma depending on the display type.
switch glwObj.displaytype
	% Bits++
	case glwObj.private.consts.displayTypes.bitspp
		% In Bits++, if no explicit non-empty gamma was asked for, we will
		% assume control of it.
		if isempty(glwObj.gamma)
			% We just zero the gamma in Bits++ mode because we'll add
			% elements to the gamma on a per object added basis.
			glwObj.gamma = zeros(256, 3);
			
			glwObj.private.autoGamma = true;
		end
		
	% HDR
	case glwObj.private.consts.displayTypes.hdr
		% If an explicit gamma was not set, then we'll make it the
		% identity.
		if isempty(glwObj.gamma)
			for wi = 1:2
				glwObj.gamma{wi} = linspace(0, 1, 256)' * [1 1 1];
			end
		end
		
	% Stereo, Stereo-Bits++
	case {glwObj.private.consts.displayTypes.stereo, ...
			glwObj.private.consts.displayTypes.stereobitspp}
		% If an explicit gamma wasn't set, the we'll make it the
		% identity.
		if isempty(glwObj.gamma)
			for wi = 1:2
				glwObj.gamma{wi} = linspace(0, 1, 256)' * [1 1 1];
			end
		end
		
	% Normal mode.
	case glwObj.private.consts.displayTypes.normal
		% Set the gamma to the identity if not specified explicitly.
		if isempty(glwObj.gamma)
			glwObj.gamma = linspace(0, 1, 256)' * [1 1 1];
		end
		
	otherwise
		error('Invalid display type "%s" specified.', glwObj.displaytype);
end
