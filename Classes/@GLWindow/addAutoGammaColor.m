function obj = addAutoGammaColor(GLWObj, obj)
% obj = addAutoGammaColor(GLWObj, obj)
%
% Description:
% Performs all actions necessary for an object to utilize the AutoGamma
% feature.  If AutoGamma isn't being used for this instance of GLWindow,
% then nothing is done and the function returns immediately.
%
% Input:
% obj (struct) - The object to be added to AutoGamma.
%
% Output:
% obj (struct) - The updated object.

if ~GLWObj.AutoGamma
	return;
end

% The object keeps track of its Bits++ index for later use.
obj.BitsPPIndex = GLWObj.BitsPPIndex;

% Increment the global Bits++ index so that the next object added has a
% fresh location to be inserted into.
GLWObj.BitsPPIndex = GLWObj.BitsPPIndex + 1;

% Update the gamma to hold the actual object color.
g = GLWObj.Gamma;
for i = 1:GLWObj.NumWindows
	g{i}(obj.BitsPPIndex,:) = obj.Color(i,:);
	
	% Stick an identity gamma in the rest of the lookup table.  This helps
	% text to be readable without doing clut tricks.
	g{i}(GLWObj.BitsPPIndex:256,:) = linspace(0, 1, 256-GLWObj.BitsPPIndex+1)' * [1 1 1];
	
end
GLWObj.Gamma = g;

% Now replace the object's color with the Bits++ lookup table index.
for i = 1:GLWObj.NumWindows
	obj.Color(i,:) = ones(1,3) * (obj.BitsPPIndex-1) / 255;
end
