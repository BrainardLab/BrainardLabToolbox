classdef GLSim
	% GLSim - Class to simulate the OpenGL transformation pipeline.
	%
	%
	
	properties
		X;
		Y;
		Z;
		
		SceneDims = [48 30];
		ScreenDistance = 50;
		HorizontalOffset = 0;
	end
	
	properties (SetAccess = protected, Dependent = true)
		ProjectionMatrix;
		ModelviewMatrix;
		EyeCoords;
		ClipCoords;
		NormalizedDeviceCoords;
		ScreenCoords;
	end
	
	properties (SetAccess = protected)
		Transformations;
	end
	
	properties (Constant = true)
		TransformationTypes = struct('Rotation', 1, ...
									 'Translation', 2);
	end
	
	methods
		function obj = GLSim(x, y, z)
			% Validate the number of inputs.
			narginchk(3, 3);
			
			obj.X = x;
			obj.Y = y;
			obj.Z = z;
		end
		
		obj = rotate(obj, rotDeg, x, y, z)
		obj = translate(obj, x, y, z);
	end
	
	% Property get/set functions.
	methods
		function S = get.ScreenCoords(obj)
			S = obj.NormalizedDeviceCoords(1:2);
			S = S .* obj.SceneDims' / 2;
		end
		
		function D = get.NormalizedDeviceCoords(obj)
			C = obj.ClipCoords;
			D = C(1:3) / C(4);
		end
		
		function C = get.ClipCoords(obj)
			C = obj.ProjectionMatrix * obj.EyeCoords;
		end
		
		function E = get.EyeCoords(obj)
			E = obj.ModelviewMatrix * [obj.X; obj.Y; obj.Z; 1];
		end
		
		function P = get.ProjectionMatrix(obj)
			[~, P] = GLWindow.calculateFrustum(obj.ScreenDistance, obj.SceneDims, obj.HorizontalOffset);
		end
		
		function M = get.ModelviewMatrix(obj)
			% Initialize the matrix to the identity.
			M = eye(4);
			
			for i = 1:length(obj.Transformations)
				M = obj.Transformations(i).M * M;
			end
			
			% Add in our screen distance.  This simulates a simplified case
			% of the gluLookAt function, which post multiplies the
			% modelview matrix.
			m = eye(4);
			m(3, 4) = -obj.ScreenDistance;
			M = m * M;
		end
	end
end
