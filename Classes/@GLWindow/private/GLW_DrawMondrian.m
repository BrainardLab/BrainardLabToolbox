function GLW_DrawMondrian(verts, polygonColor, patchDepths, patchRotations, numRows, numCols, mondrianOrigin, dimensions, border, rotation)
% GLW_DrawMondrian(verts, polygonColor, patchDepths, patchRotations, numRows, numCols, mondrianOrigin, dimensions, border, rotation)
%
% Description:
% Renders a Mondrian.

global GL;

mondrianWidth = dimensions(1);
mondrianHeight = dimensions(2);

mglTransform('GL_MODELVIEW', 'glPushMatrix');
mglTransform('GL_MODELVIEW', 'glTranslate', mondrianOrigin(1), mondrianOrigin(2), mondrianOrigin(3));
mglTransform('GL_MODELVIEW', 'glRotate', rotation(1), rotation(2), rotation(3), rotation(4));

% Calculate offsets to center the mondrian around the specified origin.
offsetX = -mondrianWidth / 2;
offsetY = -mondrianHeight / 2;

patchVerts = zeros(4,2);

% Draw the Mondrian.  Polygons are drawn in a column from bottom
% to top, columns are drawn left to right.
for c = 1:numCols % X dimension
	for r = 1:numRows % Y dimension
		% Set the polygon color.
		glColor3dv(squeeze(polygonColor(r, c, :))');
		
		% Calculate the patch vertices.
		patchVerts(1,:) = squeeze(verts(r+1, c, :))' + [offsetX, offsetY] + border;              % Lower left corner.
		patchVerts(2,:) = squeeze(verts(r, c, :))' + [offsetX, offsetY] + [border, -border];     % Upper left corner.
		patchVerts(3,:) = squeeze(verts(r, c+1, :))' + [offsetX, offsetY] - border;              % Upper right corner.
		patchVerts(4,:) = squeeze(verts(r+1, c+1, :))' + [offsetX, offsetY] + [-border, border]; % Lower right corner.
		
		mglTransform('GL_MODELVIEW', 'glPushMatrix');
		
		% Rotate the individual patch.  We do this by finding the center of
		% the patch, translating it around (0,0,0), doing the rotation,
		% then translating it back to it's original position plus the user
		% specified patch depth.
		tx = mean(patchVerts(:,1)); %max(patchVerts(:,1)) - min(patchVerts(:,1));
		ty = mean(patchVerts(:,2)); %max(patchVerts(:,2)) - min(patchVerts(:,2));
		mglTransform('GL_MODELVIEW', 'glTranslate', tx, ty, patchDepths(r,c));
		mglTransform('GL_MODELVIEW', 'glRotate', patchRotations(r,c,1), ...
			patchRotations(r,c,2), patchRotations(r,c,3), patchRotations(r,c,4));
		mglTransform('GL_MODELVIEW', 'glTranslate', -tx, -ty, 0);

		% Draw a polygon.  Notice that Matlab essentially stores
		% matrices in (y,x) order since rows imply vertical position
		% and columns imply horiztontal position.
		glBegin(GL.QUADS);
		for pv = 1:4
			glVertex2dv(patchVerts(pv,:));
		end
		glEnd;
		
		mglTransform('GL_MODELVIEW', 'glPopMatrix');
	end
end

mglTransform('GL_MODELVIEW', 'glPopMatrix');
