function DrawMaterialHDRStimulus(cal, centerRGB)
% DrawMaterialHDRStimulus(cal, centerRGB)
%
% Description:
% Draws the surround plus center color that we need to measure in
% the Material HDR calibration script.

% 11/05/10 kmo   Wrote from DrawMondrianHDRStimulus

global GL;

% Set the center square color.
cal.material.surroundColors(3,3,:) = centerRGB;

isBack = strcmp(cal.describe.monitor, 'HDRBack');

if isBack
	mglFBBegin(cal.mondrian.fbObject, cal.mondrian.fbSize);
end

% Draw the Mondrian.
HDRInitOpenGL(cal.describe.screenDims(1), cal.describe.screenDims(2));
mglClearScreen(0);
mglTransform('GL_MODELVIEW', 'glLoadIdentity');
for i = 1:size(cal.mondrian.mondrianVerts, 1)
	for j = 1:size(cal.mondrian.mondrianVerts, 2)
		glColor3dv(squeeze(cal.mondrian.surroundColors(i, j, :))');
		
		glBegin(GL.QUADS);
		glVertex2dv(cal.mondrian.mondrianVerts(i, j, 1, :));
		glVertex2dv(cal.mondrian.mondrianVerts(i, j, 2, :));
		glVertex2dv(cal.mondrian.mondrianVerts(i, j, 3, :));
		glVertex2dv(cal.mondrian.mondrianVerts(i, j, 4, :));
		glEnd;
	end
end

if isBack
	mglFBEnd;
	
	% This warps the Mondrian.
	mglClearScreen(0);
	HDRInitOpenGL(cal.describe.screenDims(1), cal.describe.screenDims(2));
	mglTransform('GL_MODELVIEW', 'glLoadIdentity');
	glBindTexture(cal.mondrian.texType, cal.mondrian.fbTexture);
	glEnable(cal.mondrian.texType);
	glColor3d(1, 1, 1);
	glCallList(cal.mondrian.warpList);
	glDisable(cal.mondrian.texType);
end

mglFlush;
