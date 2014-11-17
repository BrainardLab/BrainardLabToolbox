#include <mex.h>
#include <OpenGL/gl.h>

#define ExtractElement3D(row, col, el, numRows, numCols) ((el)*numRows*numCols + numRows*(col) + (row))

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	const mwSize *dims;
	mwSize numColumns, numRows, numCoords, row, col, coord, index = 0;
	double *warpGrid, *textureDims, *x, *y;
	GLuint list;
	int i, j, xi, yi;
	int outputDebug = 0;
	
	// Pull out the 2 arrays passed to the function.
	warpGrid = mxGetPr(prhs[0]);
	textureDims = mxGetPr(prhs[1]);
	
	// Grab the dimensions from the warp grid.
	dims = mxGetDimensions(prhs[0]);
	numColumns = dims[1];
	numRows = dims[0];
	numCoords = dims[2];
	
	list = glGenLists(1);
	glNewList(list, GL_COMPILE);
	
	// Create the arrays we'll use to reference a single grid in texture
	// coordinates.
	x = (double*)mxMalloc(sizeof(double) * numColumns);
	y = (double*)mxMalloc(sizeof(double) * numRows);
	for (i = 0; i < numColumns; i++) {
		x[i] = 1.0 / (double)(numColumns-1) * i;
	}
	for (i = 0; i < numRows; i++) {
		y[i] = 1.0 / (double)(numRows-1) * i;
	}
	
	for (col = 0; col < numColumns - 1; col++) {
		for (row = 0; row < numRows - 1; row++) {
			glBegin(GL_QUADS);
			
			xi = col;
			yi = numRows - row - 1;
			
			// Bottom left corner
			glTexCoord2d(x[col]*textureDims[0], y[row]*textureDims[1]);
			i = ExtractElement3D(yi, xi, 0, numRows, numColumns);
			j = ExtractElement3D(yi, xi, 1, numRows, numColumns);
			glVertex2d(warpGrid[i], warpGrid[j]);
			
			// Bottom right corner
			glTexCoord2d(x[col+1]*textureDims[0], y[row]*textureDims[1]);
			i = ExtractElement3D(yi, xi+1, 0, numRows, numColumns);
			j = ExtractElement3D(yi, xi+1, 1, numRows, numColumns);
			glVertex2d(warpGrid[i], warpGrid[j]);
			
			// Upper right corner
			glTexCoord2d(x[col+1]*textureDims[0], y[row+1]*textureDims[1]);
			i = ExtractElement3D(yi-1, xi+1, 0, numRows, numColumns);
			j = ExtractElement3D(yi-1, xi+1, 1, numRows, numColumns);
			glVertex2d(warpGrid[i], warpGrid[j]);
			
			// Upper left corner
			glTexCoord2d(x[col]*textureDims[0], y[row+1]*textureDims[1]);
			i = ExtractElement3D(yi-1, xi, 0, numRows, numColumns);
			j = ExtractElement3D(yi-1, xi, 1, numRows, numColumns);
			glVertex2d(warpGrid[i], warpGrid[j]);

			glEnd();
		}
	}

	glEndList();
	
	// Return the list ID.
	plhs[0] = mxCreateDoubleScalar((double)list);
	
	// Delete our dynamically allocated memory.
	mxFree(x);
	mxFree(y);
}
