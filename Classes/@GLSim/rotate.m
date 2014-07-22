function obj = rotate(obj, rotDeg, x, y, z)

% Validate the number of inputs.
error(nargchk(4, 5, nargin));

if nargin == 4
	z = 0;
end

% Normalize the rotation vector.
l = sqrt(x^2 + y^2 + z^2);
x = x/l;
y = y/l;
z = z/l;

% Convert degrees to radians.
theta = rotDeg / 180 * pi;

% We want to stick the new transformation at the end of the transformations
% queue.
i = length(obj.Transformations) + 1;

obj.Transformations(i).type = GLSim.TransformationTypes.Rotation;

% Create the rotation matrix.  The equation used is documented here
% http://www.cs.rutgers.edu/~decarlo/428/gl_man/rotate.html
c = cos(theta);
s = sin(theta);
obj.Transformations(i).M = [x*x*(1-c)+c, x*y*(1-c)-z*s, x*z*(1-c)+y*s, 0 ; ...
							y*x*(1-c)+z*s, y*y*(1-c)+c, y*z*(1-c)-x*s, 0 ; ...
							x*z*(1-c)-y*s, y*z*(1-c)+x*s, z*z*(1-c)+c, 0 ; ...
							0, 0, 0, 1];
						