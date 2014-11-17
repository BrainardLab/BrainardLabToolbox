function validatedGamma = GLW_ValidateGammaRange(desiredGamma)
% validatedGamma = GLW_ValidateGammaRange(desiredGamma)
%
% Description:
% Checks to see if the gamma is in the [0,1] range.
%
% Input:
% desiredGamma (256x3|struct) - Desired gamma.  If a struct, all fields
% will be checked to be 256x3 matrices in addition to being range checked.
%
% Output:
% validatedGamma (256x3|struct) - The validated gamma.

if isstruct(desiredGamma)
	fNames = fieldnames(desiredGamma);
	
	for i = 1:length(fNames)
		data = desiredGamma.(fNames{i});
		
		if any(data > 1) || any(data < 0)
			error('Gamma values must be in the range [0,1].');
		end
	end
elseif all(size(desiredGamma) == [256 3])
	if any(desiredGamma > 1) || any(desiredGamma < 0)
		error('Gamma values must be in the range [0,1].');
	end
else
	error('"desiredGamma" must be a 256x3 matrix or a struct');
end

validatedGamma = desiredGamma;
