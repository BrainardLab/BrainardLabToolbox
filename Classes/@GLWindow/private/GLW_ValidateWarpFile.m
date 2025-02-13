function validatedWarpFile = GLW_ValidateWarpFile(desiredWarpFile, displayTypeID)
% GLW_ValidateWarpFile - Validates the warp file(s).
%
% Syntax:
% validatedWarpFile = GLW_ValidateWarpFile(desiredWarpFile, displayTypeID)
%
% Description:
% Validates the name(s) of the warpfile(s) to be used.
%
% Input:
% desiredWarpFile (string|cell array|[]) - The name(s) of the calibration file(s) containing
%     the warping information.
% displayTypeID (integer) - The display ID type of the GLWindow.
%     This value should be generated by GLW_ValidateDisplayType.
%
% Output:
% validatedWarpFile (cell array) - Validated name(s) of the warp file(s).

switch displayTypeID
	case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
		if isempty(desiredWarpFile)
			desiredWarpFile = {};
		elseif iscell(desiredWarpFile)
			% Make sure there is only 1 cell.
			if length(desiredWarpFile) ~= 1
				error('"desiredWarpFile" can only have 1 cell entry.');
			end
			
			% Make sure a string is in the cell.
			if ~ischar(desiredWarpFile{1})
				error('The cell contents of "desiredWarpFile" must be a string.');
			end
		elseif ischar(desiredWarpFile)
			desiredWarpFile = {desiredWarpFile};
		end
		
	case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP}
		% For stereo/stereo Bits++ mode, we need a struct passed with 2
		% fields: leftGamma and rightGamma, or  a cell array.
		if isstruct(desiredWarpFile)
			% Now make sure we have both fields and that they contain legit
			% gamma tables.
			GLW_ValidateStructFields(desiredWarpFile,  {'left', 'right'})
			
			desiredWarpFile = {desiredWarpFile.left, desiredWarpFile.right};
		elseif iscell(desiredWarpFile)
			% Make sure there are only 2 elements to the cell array.
			% One element for the left and one for the right.
			if length(desiredWarpFile) ~= 2
				error('"desiredWarpFile" must be a 2 element cell array in stereo mode.');
			end
			
			% Both elements of the cell array must be strings.
			for i = 1:length(desiredWarpFile)
				if ~ischar(desiredWarpFile{i})
					error('The cell contents of "desiredWarpFile" must be a strings.');
				end
			end
		elseif isempty(desiredWarpFile)
			error('Warp files must be explicitly set in stereo mode.');
		else
			error('In stereo mode the warp file must be passed as a struct or cell array.');
		end
		
	case GLWindow.DisplayTypes.HDR
		if isempty(desiredWarpFile)
			error('A warp file must be explicitly set in HDR mode.');
		elseif iscell(desiredWarpFile)
			% Make sure there is only 1 cell.
			if length(desiredWarpFile) ~= 1
				error('"desiredWarpFile" can only have 1 cell entry.');
			end
			
			% Make sure a string is in the cell.
			if ~ischar(desiredWarpFile{1})
				error('The cell contents of "desiredWarpFile" must be a string.');
			end
		elseif ischar(desiredWarpFile)
			desiredWarpFile = {desiredWarpFile};
		end
		
	case GLWindow.DisplayTypes.StereoHDR
		% Number of warp files needed for this display type.
		numWarpFiles = length(GLWindow.DisplayFields.StereoHDR);
		
		if isempty(desiredWarpFile)
			error('Warp files must be explicitly set in Stereo HDR mode.');
		elseif isstruct(desiredWarpFile)
			% Make sure we have the right fields for the struct.
			GLW_ValidateStructFields(desiredWarpFile, GLWindow.DisplayFields.StereoHDR);
			
			% Stuff the struct data into a cell array.
			w = cell(1, numWarpFiles);
			for i = 1:numWarpFiles
				w{i} = desiredWarpFile.(GLWindow.DisplayFields.StereoHDR{i});
			end
			desiredWarpFile = w;
		elseif iscell(desiredWarpFile)
			% Make sure the cell array is a vector of the right length.
			assert(isvector(desiredWarpFile && length(desiredWarpFile) == numWarpFiles), ...
				'GLW_ValidateWarpFile:InvalidDims', ...
				'Warp file(s) defined as a cell array must have %d elements.', ...
				numWarpFiles);
		
			% Make sure all elements are strings.
			for i = 1:numWarpFiles
				assert(ischar(desiredWarpFile{i}), 'GLW_ValidateWarpFile:BadContent', ...
					'Warp file(s) defined in a cell array must be strings.');
			end
		else
			error('In Stereo HDR mode, warp files must be specified in a struct or cell array.');
		end
		
	otherwise
		error('Unknown display type ID: %d.', displayTypeID);
end

validatedWarpFile = desiredWarpFile;
