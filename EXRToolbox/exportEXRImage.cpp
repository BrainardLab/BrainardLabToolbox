/*=================================================================================
 * exportEXRImage.cpp
 *
 * This file writes a N x M x K matrix into an EXR file
 * wher K is the number of channels.
 *
 * 2015         Francesco Banterle      Wrote it (based on Syoyo Fujita's tinyexr)
 * 10/20/2019   Nicolas P. Cottaris     Updated to support multi-channel EXR files
 *
 *===============================================================================*/
 

#include "mex.h"
#include <vector>
#include <string>

#define TINYEXR_IMPLEMENTATION

#define MAX_CHANNELS_NUM 1000
#define MAX_CHANNEL_NAME_LENGTH 100

#include "tinyexr.h"

/* The computational routine */
bool writeImage(char *nameFile, double *data, int width, int height, int channels, char desiredChannelNames[MAX_CHANNELS_NUM][MAX_CHANNEL_NAME_LENGTH])
{
     EXRImage image;
     InitEXRImage(&image);
 
     image.num_channels = channels;

     if (channels > MAX_CHANNELS_NUM) {
         printf("Save EXR is limited to %d channels. This image has %d channels.\n", MAX_CHANNELS_NUM, channels);
         return false;
     }
     
     const char* channel_names[channels];
     for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
         channel_names[channelIndex] = desiredChannelNames[channelIndex];
     }
     
     std::vector<float> images[channels];
     for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
         images[channelIndex].resize(width * height);
     }

     int nPixels = width * height;
     
     if(channels == 1) {
         nPixels = 0;
     }
        
     for (int i = 0; i < width; i++){
         for (int j = 0; j < height; j++){
             int index = i * height + j;
             int indexOut = j * width + i;
             for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
                 images[channelIndex][indexOut] = data[index + nPixels*channelIndex];
             }
         }
     }

     float* image_ptr[channels];
     for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
         image_ptr[channelIndex] = &(images[channelIndex].at(0));
     }

     image.channel_names = channel_names;
     image.images = (unsigned char**)image_ptr;
     image.width = width;
     image.height = height;

     image.pixel_types = (int *)malloc(sizeof(int) * image.num_channels);
     image.requested_pixel_types = (int *)malloc(sizeof(int) * image.num_channels);
     for (int i = 0; i < image.num_channels; i++) {
       image.pixel_types[i] = TINYEXR_PIXELTYPE_FLOAT; // pixel type of input image
       image.requested_pixel_types[i] = TINYEXR_PIXELTYPE_HALF; // pixel type of output image to be stored in .EXR
     }

     const char* err;
     int ret = SaveMultiChannelEXRToFile(&image, nameFile, &err);
     if (ret != 0) {
         printf("Save EXR err: %s\n", err);
         return false;
     }

     //FreeEXRImage(&image);

     free(image.pixel_types);
     free(image.requested_pixel_types);
     
     return true;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inMatrix;

    /* check for proper number of arguments */
    if(nrhs != 3) {
        mexErrMsgIdAndTxt("EXRToolbox:exportEXRImage:nrhs", "Three inputs are required.");
    }
    
    if (mxIsClass(prhs[2],"cell") != 1) {
        mexErrMsgIdAndTxt("EXRToolbox:exportEXRImage:nrhs", "Third argument must be a cell array.");
    }
    
    /* create a pointer to the real data in the input matrix  */
    inMatrix = mxGetPr(prhs[1]);
    
    char *buf;
    mwSize buflen;
    int status;    
    buflen = mxGetN(prhs[0])*sizeof(mxChar)+1;
    buf = (char*) mxMalloc(buflen);
    
    /* Copy the string data into buf. */ 
    status = mxGetString(prhs[0], buf, buflen);   
    
    /* Get the dimensions of the input matrix */
    const mwSize *dims;
    dims = mxGetDimensions(prhs[1]);
       
    int nDim = (int)mxGetNumberOfDimensions(prhs[1]);

    int channels;
    if(nDim == 2) {
        channels = 1;
    } else {
      channels = dims[2];
    }
    
    // Get the channel names
    const mxArray *cellArray;
    const mwSize *cellArrayDims;
    
    cellArray = prhs[2];
    cellArrayDims = mxGetDimensions(prhs[2]);
      
    /* call the computational routine */
    if(dims[0] > 0 && dims[1] > 0) {
        
        char channel_names[MAX_CHANNELS_NUM][MAX_CHANNEL_NAME_LENGTH];
        char *namebuf;
        
        for (int channelIndex = 0; channelIndex < channels; channelIndex++) {
            mxArray *theCell;
            theCell = mxGetCell(cellArray, channelIndex);
            if (mxIsChar(theCell)) {
                /* Find out how long the input string array is. */
                size_t buflen = (mxGetM(theCell) * mxGetN(theCell)) + 1;

                /* Allocate enough memory to hold the converted string. */ 
                
                namebuf = (char*)mxCalloc(buflen, sizeof(char));
                if (namebuf == NULL) {
                    printf("Could not allocate memory\n");
                }
                else {
                    status = mxGetString(theCell, namebuf, buflen); 
                    sprintf(channel_names[channelIndex], "%s", namebuf);
                }
            }
            else {
                mexErrMsgIdAndTxt("EXRToolbox:exportEXRImage:nrhs", "Cell element must be a char string.");
            }
        }
        
        writeImage(buf, inMatrix, dims[1], dims[0], channels, channel_names );
    } else {
        printf("This matrix is not valid and the exr file cannot be written on the disk!\n");
    }
}
