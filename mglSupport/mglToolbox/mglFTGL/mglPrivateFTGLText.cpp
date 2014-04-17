#include <mex.h>
#include <FTGL/ftgl.h>

typedef struct
{
	FTFont *font;
	FTPoint *position;
} FontObject;

FontObject* createFontObject(const char *fontPath, const unsigned int fontSize);
static void smiteFontObject(void);

static FontObject *g_fontObject = NULL;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mwIndex commandCode;
	
	// Make sure at least a command code was passed.
	if (nrhs < 1) {
		mexErrMsgTxt("Command code not passed.");
	}
	
	if (g_fontObject == NULL) {
		g_fontObject = createFontObject("/Library/Fonts/Arial.ttf", 72);
		
		mexAtExit(smiteFontObject);
	}
	
	// Pull out the command code.
	commandCode = (mwIndex)mxGetScalar(prhs[0]);
		
	switch (commandCode)
	{			
		// RenderText
		case 1:
			char textString[256];
			
			// Make sure that the right number of parameters were passed.
			if (nrhs != 2) {
				mexErrMsgTxt("Usage: mglPrivateFTGLText(1, textString)");
			}
			
			// Pull out the text string to render.
			if (mxGetString(prhs[1], textString, mxGetN(prhs[1]) + 1)) {
				mexErrMsgTxt("RenderText: Could not get the text string.");
			}
			
			// Render the text.
			g_fontObject->font->Render(textString, -1, g_fontObject->position);
			
			break;
			
		// Initialize
		case 2:
			// Do nothing here.  This case is only here so that someone can call
			// this function at the beginning of their program to get the default
			// font object loaded into memory.
			break;
			
		// Set the font size.
		case 3:
			int fontSize;
			
			// Verify number of inputs.
			if (nrhs != 2) {
				mexErrMsgTxt("Usage: mglPrivateFTGLText(3, fontSize)");
			}
			
			// Pull out the font size.
			fontSize = (int)mxGetScalar(prhs[1]);
			
			// Set the font size.
			g_fontObject->font->FaceSize((const unsigned int)fontSize);
			
			break;
			
		default:
			mexErrMsgTxt("Received invalid command code");
	}	
}


FontObject* createFontObject(const char *fontPath, const unsigned int fontSize)
{
	FontObject fobj = new FontObject;
	
	// Create the font object if it hasn't already been created.
	fobj->font = new FTGLPixmapFont(fontPath);
	
	if (fobj->font->Error()) {
		mexErrMsgTxt("Error creating the font object.");
	}
	
	// Default font size.
	fobj->font->FaceSize(72);
	
	return fobj;
}


static void smiteFontObject(void)
{
	if (g_fontObject != NULL) {
		delete g_fontObject->font;
		delete g_fontObject;
		g_fontObject = NULL;
	}
}
