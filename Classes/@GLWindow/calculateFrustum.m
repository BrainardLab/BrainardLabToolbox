function [frustum, projectionMatrix] = calculateFrustum(screenDistance, screenDims, horizontalOffset)
% calculateFrustum - Calculates the frustum values for glFrustum.
%
% Syntax:
% [frustum, projectionMatrix] = calculateFrustum(screenDistance, screenDims, horizontalOffset)
% 
% Description:
% Takes some basic screen information and calculates the frustum parameters
% required to setup a 3D projection matrix.  Also returns the projection
% matrix that will be generated using the frustum parameters.  The equation
% used to generate the projection matrix can be found in the OpenGL
% glFrustum documentation.
%
% Input:
% screenDistance (scalar) - Distance from the screen to the observer.
% screenDims (1x2) - Dimensions of the screen. (width, height)
% horizontal offset (scalar) - Horizontal shift of the observer from the
%     center of the display.  Should be 0 for regular displays and half the
%     interocular distance for stereo setups.
%
% Output:
% frustum (struct) - Struct containing all calculated frustum parameters.
%     Contains the following fields.
%     1. left - Left edge of the near clipping plane.
%	  2. right - Right edge of the near clipping plane.
%	  3. top - Top edge of the near clipping plane.
%	  4. bottom - Bottom edge of the near clipping plane.
%	  5. near - Distance from the observer to the near clipping plane.
%	  6. far - Distance from the observer to the far clipping plane.
% projectionMatrix (4x4) - The resulting projection matrix used by OpenGL
%     given the generated frustum.
%
%
% 4/9/12 TYL - increased frustum.far value


if nargin ~= 3
	error('Usage: frustum = calculateFrustum(screenDistance, screenDims, horizontalOffset)');
end

% I chose these constants as reasonable values for the distances from the
% camera for the type of experiments the Brainard lab does.
frustum.near = 1;
frustum.far = 1000;

% Use similar triangles to figure out the boundaries of the near clipping
% plane based on the information about the screen size and its distance
% from the camera.
frustum.right = (screenDims(1)/2 - horizontalOffset) * frustum.near / screenDistance;
frustum.left = -(screenDims(1)/2 + horizontalOffset) * frustum.near / screenDistance;
frustum.top = screenDims(2)/2 * frustum.near /  screenDistance;
frustum.bottom = -frustum.top;

% Now calculate the projection matrix.
A = (frustum.right + frustum.left) / (frustum.right - frustum.left);
B = (frustum.top + frustum.bottom) / (frustum.top - frustum.bottom);
C = (frustum.far + frustum.near) / (frustum.far - frustum.near);
D = 2 * frustum.far * frustum.near / (frustum.far - frustum.near);
v1 = 2 * frustum.near / (frustum.right - frustum.left);
v2 = 2 * frustum.near / (frustum.top - frustum.bottom);
projectionMatrix = [v1 0 A 0 ; 0 v2 B 0 ; 0 0 C D ; 0 0 -1 0];
