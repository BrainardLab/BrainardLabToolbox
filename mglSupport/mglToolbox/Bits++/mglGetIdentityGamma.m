function identityGamma = mglGetIdentityGamma
% identityGamma = mglGetIdentityGamma
%
% Description:
% Gets the proper identity gamma for the hardware on this machine to make
% Bits++ work correctly.
%
% Output:
% identityGamma (256x3 double) - The correct identity gamma.

% Gets the OpenGL info on this machine.
% openGLData = opengl('data');

% openGLData.Renderer = 'NVIDIA GeForce GT 120 OpenGL Engine';
% 
% % Look to see what video card we're using, and choose the identity gamma
% % accordingly.
% switch openGLData.Renderer
% 	case 'NVIDIA GeForce GT 120 OpenGL Engine'
% 		identityGamma = linspace(0, 1023/1024, 256)' * [1 1 1];
		
% 	otherwise
		identityGamma = linspace(0, 1, 256)' * [1 1 1];
% end
