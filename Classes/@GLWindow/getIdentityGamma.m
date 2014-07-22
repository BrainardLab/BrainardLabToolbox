function identityGamma = getIdentityGamma
% identityGamma = getIdentityGamma
%
% Description:
% Gets the proper identity gamma for this type of hardware.  This function 
% assumes all video cards are of the same type in the computer.
%
% Output:
% identityGamma (256x3) - The matrix representing the identity gamma for
%   the video card on the computer.

persistent openGLData iGamma

if isempty(openGLData)
	% Gets the OpenGL info on this machine.
	openGLData = opengl('data');
	
	% Look to see what video card we're using, and choose the identity gamma
	% accordingly.
	switch openGLData.Renderer
		case 'NVIDIA GeForce GT 120 OpenGL Engine'
			iGamma = linspace(0, 1023/1024, 256)' * [1 1 1];
			
		otherwise
			iGamma = linspace(0, 1, 256)' * [1 1 1];
	end
end

identityGamma = iGamma;
