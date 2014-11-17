function setGamma(GLWObj, gammaTable)
% setGamma(gammaTable)
%
% Description:
% Validates and sets the gamma table for any windows controlled
% by the GLWindow object.
%
% Input:
% gammaTable - 

if nargin ~= 2
	error('Usage: setGamma(gammaTable)');
end

% A value of NaN or empty tells the GLWindow that we should use the
% identity.  Otherwise, we need to make sure the input is valid.
if isnan(gammaTable) || isempty(gammaTable)
	switch GLWObj.DisplayTypeID
		case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
			validatedGamma = linspace(0,1,256)' * [1 1 1];
			
		case {GLWindow.DisplayTypes.BitsPP}
			validatedGamma.leftGamma = linspace(0,1,256)' * [1 1 1];
			validatedGamma.rightGamma = linspace(0,1,256)' * [1 1 1];
			
		otherwise
			error('Invalid display type "%s".', displayTypeID);
	end
	
	gammaTable = validatedGamma;
else
	switch displayTypeID
		case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
			% For these modes the gamma must be a 256x3 matrix.
			if ~all(size(gammaTable) == [256 3])
				error('In "%s" display mode, the gamma must be a 256x3 matrix.', displayTypeID);
			end
			
		case GLWindow.DisplayTypes.StereoBitsPP
			% For stereo Bits++ mode, we need a struct passed with 2
			% fields: leftGamma and rightGamma.
			if ~isstruct(gammaTable)
				error('In stereo-bits++ mode the gamma must be passed as a struct.');
			end
			
			% Now make sure we have both fields and that they contain legit
			% gamma tables.
			GLWindow.validateStructFields(gammaTable, {'leftGamma', 'rightGamma'});
			
		otherwise
			error('Invalid display type "%s".', displayTypeID);
	end
end

% Make sure all values are in the [0,1] range.
GLWObj.Gamma = validateGammaRange(gammaTable);


function validatedGamma = validateGammaRange(gammaTable)
% validatedGamma = validateGammaRange(gammaTable)
%
% Description:
% Checks to see if the gamma values passed are in the [0,1] range.
%
% Input:
% gammaTable (256x3|struct) - Desired gamma.  If a struct, all fields
% will be checked to be 256x3 matrices in addition to being range checked.
%
% Output:
% validatedGamma (256x3|struct) - The validated gamma.
if isstruct(gammaTable)
	fNames = fieldnames(gammaTable);
	
	for i = 1:length(fNames)
		data = gammaTable.(fNames{i});
		
		if any(data > 1) || any(data < 0)
			error('Gamma values must be in the range [0,1].');
		end
	end
elseif all(size(gammaTable) == [256 3])
	if any(gammaTable > 1) || any(gammaTable < 0)
		error('Gamma values must be in the range [0,1].');
	end
else
	error('"gammaTable" must be a 256x3 matrix or a struct');
end

validatedGamma = gammaTable;
