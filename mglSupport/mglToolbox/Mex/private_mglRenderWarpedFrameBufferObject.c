#include <mex.h>
#include <OpenGL/gl.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *screenDims;
	GLuint texture, warpList;
	
	// Grab the texture ID.
	texture = (GLuint)mxGetScalar(prhs[0]);
	
	// Get the warp list ID.
	warpList = (GLuint)mxGetScalar(prhs[1]);
	
	// Get the scene dimensions.
	screenDims = mxGetPr(prhs[2]);
	
 	// Clear the screen.
 	glClearColor(0, 0, 0, 0);
 	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
 	
	// Setup the scene dimensions.
	glEnable(GL_BLEND);
	glEnable(GL_POLYGON_SMOOTH);
	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-screenDims[0]/2.0, screenDims[0]/2.0, -screenDims[1]/2.0, screenDims[1]/2.0, 0.0, 1.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	// Render the frame buffer object.
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glColor3d(1, 1, 1);
	glCallList(warpList);
	glDisable(GL_TEXTURE_RECTANGLE_ARB);
}
