function obj = translate(obj, x, y, z)

% Validate the number of inputs.
narginchk(4, 4);

% We want to stick the new transformation at the end of the transformations
% queue.
i = length(obj.Transformations) + 1;

obj.Transformations(i).type = GLSim.TransformationTypes.Translation;
obj.Transformations(i).M = [1 0 0 x; ...
							0 1 0 y; ...
							0 0 1 z; ...
							0 0 0 1];
						