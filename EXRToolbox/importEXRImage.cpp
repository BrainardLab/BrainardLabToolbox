/*=================================================================================
 * importEXRImage.cpp
 *
 * This file reads a N x M x K matrix into an EXR file
 * wher K is the number of channels..
 *
 * 2015         Francesco Banterle  Wrote it (based on Syoyo Fujita's tinyexr)
 * 10/20/2019   Nicolas P. Cottaris Updated to support multi-channel EXR files
 *
 *===============================================================================*/


#include "mex.h"
#include <vector>
#include <string>

#define TINYEXR_IMPLEMENTATION

#include "tinyexr.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    /* check for proper number of arguments */
    if(nrhs != 1) {
        mexErrMsgIdAndTxt("EXRToolbox:write_exr:nrhs", "One input is required.");
    }
    
    char *nameFile;
    mwSize buflen;
    int status;    
    buflen = mxGetN(prhs[0])*sizeof(mxChar)+1;
    nameFile = (char*) mxMalloc(buflen);
    
    /* Copy the string data into buf. */ 
    status = mxGetString(prhs[0], nameFile, buflen);
    
    /* call the computational routine */
    EXRImage image;
    InitEXRImage(&image);

    const char* err;
    int ret = ParseMultiChannelEXRHeaderFromFile(&image, nameFile, &err);
    if (ret != 0) {
        printf("Parse EXR error: %s\n", err);
        return;
    }

    int width = image.width;
    int height = image.height;
    int channels = image.num_channels;

    //Allocate into memory

    mwSize dims[3];
    dims[0] = height;
    dims[1] = width;
    dims[2] = channels;

    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    double *outMatrix = mxGetPr(plhs[0]);

    for (int i = 0; i < image.num_channels; i++) {
        if (image.pixel_types[i] == TINYEXR_PIXELTYPE_HALF) {
            image.requested_pixel_types[i] = TINYEXR_PIXELTYPE_FLOAT;
        }
    }
    
    // Return channel names
    if (nlhs == 2) {
        mxArray *channelNamesArray = mxCreateCellMatrix(image.num_channels, 1);
        for (mwIndex k = 0; k < image.num_channels; k++) {
            mxSetCell(channelNamesArray, k, mxCreateString(image.channel_names[k]));
        }
        plhs[1] = channelNamesArray;
    }
            
    ret = LoadMultiChannelEXRFromFile(&image, nameFile, &err);
    
    if (ret != 0) {
        printf("Load EXR error: %s\n", err);
        return;
    }
    
    
    float **images = (float**) image.images;
    int nPixels = width * height;
    if(channels == 1) {
        nPixels = 0;
    }

    for (int i = 0; i < width; i++){
        for (int j = 0; j < height; j++){
            int index = i * height + j;
            int indexOut = j * width + i;
            for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
                outMatrix[index + nPixels*channelIndex]  = images[channelIndex][indexOut];
            }
        }
    }
    
    FreeEXRImage(&image);
}
