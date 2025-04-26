/*
% CR250_device - MEX driver for controlling the CR250 Colorimeter.
%
%
% AVAILABLE COMMANDS:
%
% EXAMPLE USAGE:
%
%
% HISTORY:
% 4/10/2025   NPC    Wrote it.
% 
*/

#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/time.h>

/*
 * FOR SOME REASON, IF THE STREAMING BUFFER IS LESS THAN A LIMIT
 * WE FAIL TO REPEATEDLY STREAM. THIS LIMIT MAY BE DIFFERENT IN
 * DIFFERENT COMPUTER SYSTEMS. ON MY iMAC A VALUE OF 1000 IS THE MINIMUM
 * VALUE THAT ELIMINATES THIS PROBLEM. THIS CORRESPONDS TO A MINIMUM 
 * STREAMING DURATION OF 1.3 SECONDS
*/
#define MINIMUM_STREAMING_BUFFER_SIZE   1000
#define OPERAND_NAME_LENGTH             32
#define MAX_INPUT_BUFFER_SIZE           8192
#define MAX_COMMAND_BUFFER_SIZE         4096

enum {
    SET_VERBOSITY_LEVEL_ID = 1,
	OPEN_PORT_OPERAND_ID,
	CLOSE_PORT_OPERAND_ID,
	UPDATE_PORT_SETTINGS_OPERAND_ID,
	READ_PORT_OPERAND_ID,
	WRITE_PORT_OPERAND_ID,
	SEND_COMMAND_OPERAND_ID
};

typedef struct {
	char	name[OPERAND_NAME_LENGTH];		/* operand name */
	int		ID;				  				/* operand ID   */
} operandEntry;

static operandEntry operandDictionary[] = {
        { "setVerbosityLevel",  SET_VERBOSITY_LEVEL_ID},
    	{ "open",               OPEN_PORT_OPERAND_ID  },
    	{ "close",              CLOSE_PORT_OPERAND_ID },
    	{ "updateSettings",     UPDATE_PORT_SETTINGS_OPERAND_ID },
    	{ "readPort",           READ_PORT_OPERAND_ID },
    	{ "writePort",          WRITE_PORT_OPERAND_ID },
    	{ "sendCommand",        SEND_COMMAND_OPERAND_ID }
};

/*
 * Control commands sent to Klein10A
*/

typedef struct {
	char	ID[128];						/* command ID (128)*/
	char    description[1024];			   	/* command descriptor string */
	int     charsNumToBeReturned;       	/* chars expected in result */
	int     timeOutSeconds;             	/* timeout (in seconds) to wait before reading back the result */
} commandEntry;


static commandEntry commandDictionary[] = {
	{ "RC ID",                 "deviceID",              19,   2},
    { "RC Model",              "deviceModel",           22,   2},
    { "RC InstrumentType",     "deviceType",            26,   2},
    { "RC Firmware",           "deviceFirmware",        29,   2},
    { "RC Aperture",           "deviceAperture",        29,   2},
    { "RS Aperture",           "deviceApertureName",    24,   2},
    { "RC Accessory",          "deviceAccesories",      42,   2},
    { "RC Filter",             "deviceFilter",          18,   2},
    { "RC SyncMode",           "availableSyncModes",    63,   2},
    { "SM SyncMode 0",         "setSyncMode0",          28,   2},
    { "SM SyncMode 1",         "setSyncMode1",          39,   2},
    { "SM SyncMode 2",         "setSyncMode2",          28,   2},
    { "SM SyncMode 3",         "setSyncMode3",          28,   2},
    { "SM SyncMode 4",         "setSyncMode4",          28,   2},
    { "SM SyncMode 5",         "setSyncMode5",          28,   2},
    { "RS SyncMode",           "getCurrentSyncMode",      -1,   1}, 
    { "RS SyncFreq",           "getCurentSyncFrequency",  27,   1},
    { "SM SyncFreq",           "setSyncFrequency",       28,   2},
    { "SM Speed 0",            "setSlowSpeedMode",       25,   2},
    { "SM Speed 1",            "setNormalSpeedMode",     25,   2},
    { "SM Speed 2",            "setFastSpeedMode",       25,   2},
    { "SM Speed 3",            "set2XFastSpeedMode",     25,   2},
    { "RS Speed",              "getCurentSpeedMode",     25,   2},
    { "E",                     "toggleEcho",            -1,   2},
    { "M",                     "measure",               18,   25},
    { "RM Radiometric",       "retrieve radiometric units", 43, 2},
    { "RM Spectrum",           "retrieve measurement: spectrum",  2249,   3},
};


/* device handle to the CR250 */
static int CR250_devHandle = 0;
static int verbosityLevel = 10;

/* Principal method definitions */
int openCR250Port(char *serialPortString, int *deviceHandle);
int closeCR250Port(int *deviceHandle);
int updateCR250PortSettings(int *deviceHandle, int speed, int wordSize, int parity, int timeOut);
int readCR250Port(int *deviceHandle, unsigned char *inputBuffer, int *inputBufferSize);
int writeCR250Port(int *deviceHandle, char *outputBuffer, int outputBufferSize);
int pollCR250PortUsingMethod1(int *deviceHandle, int expectedCharsNum, int timeOutSeconds, int sleepTimeInMilliseconds, int *timedOut, char  *resultsBuffer, int *bytesRead);
int pollCR250Port(int *deviceHandle, int expectedCharsNum, int timeOutSeconds, int sleepTimeInMilliseconds, int *timedOut, char  *resultsBuffer, int resultsBufferLength, int *bytesRead);

/* Helper method definitions */
int  timeval_subtract(struct timeval *result, struct timeval *t2, struct timeval *t1);
void timeval_print(struct timeval *tv);


/* Getaway function */
void mexFunction(int nlhs,      /* number of output (return) arguments */
      mxArray *plhs[],          /* pointer to an array which will hold the output data, each element is of type: mxArray */
      int nrhs,                 /* number of input arguments */
      const mxArray *prhs[]     /* pointer to an array which holds the input data, each element is of type: const mxArray */
      )
{
    
    /* Create an 1x1 array of unsigned 32-bit integer to store the status  */
    /* This will be the first output argument */
    size_t dims[] = {1, 1};
    int nDims = 2;
    plhs[0] = mxCreateNumericArray(nDims, dims, mxINT32_CLASS, mxREAL);
    int *status;
    status = (int *) mxGetData(plhs[0]);
    
    *status = 0;
    
    
    // Check for at least 1 input argument
    if (nrhs < 1) {
        mexErrMsgTxt("CR250: Requires at least one input argument.");
    }

    // Get the first input argument (operand name)
    char operandName[OPERAND_NAME_LENGTH];
    if (mxIsChar(prhs[0]) != 1)
        mexErrMsgTxt("CR250: First argument must be an operation string.");
	else
		mxGetString(prhs[0], operandName, sizeof(operandName));
    
    
    // Find operand ID
	int operandID = 0;
	for (int i = 0; i < sizeof(operandDictionary)/sizeof(operandEntry); i++) {
		if (strcmp(operandDictionary[i].name, operandName) == 0 ) {
			operandID = operandDictionary[i].ID;
			break;
		}
	}
 
    char errorMessage[256];
    unsigned char inputBuffer[MAX_INPUT_BUFFER_SIZE];
    int inputBufferSize;
            
    if (operandID == 0) {
        sprintf(errorMessage,"CR250: Operation - %s - not recognized or implemented.", operandName);
        mexErrMsgTxt(errorMessage);
    }
    
    // Execute operand
    switch (operandID) {  
        // Operand: Set Verbosity Level
        case SET_VERBOSITY_LEVEL_ID:
            // Check for at least 2 input arguments
    		if (nrhs != 2) {
        		mexErrMsgTxt("CR250: 'updateVerbosity' requires two input arguments.");
    		}
           verbosityLevel = (int) mxGetScalar(prhs[1]);
           mexPrintf("CR250: Set verbosity level to %d\n", verbosityLevel);
           *status = 0;
           return;
        
        // Operand: Open CR250 port
        case OPEN_PORT_OPERAND_ID:
            // Check whether the second argument is a string (port device name)    
			if (mxIsChar(prhs[1]) != 1) {
                *status = -99;
        		mexErrMsgTxt("CR250: Serial port name must be a string, e.g., '/dev/tty.usbserial-KU000000'.");
        	}
            // Get the serial port string (second input argument)
            char serialPortString[256];
            mxGetString(prhs[1], serialPortString, sizeof(serialPortString));   
            // Attempt to open the port
    		*status = openCR250Port(serialPortString, &CR250_devHandle);
            // Report result
            if (*status == -1) {
                mexErrMsgTxt("CR250: Failed to open serial port device. Is the CR250 connected ? Do you see a 'tty.usbmodemA009271' when doing 'ls -al /dev/tty.*'? If not reboot.");
            }
            else if (*status == 0) {
                if (verbosityLevel >= 10)
                    mexPrintf("CR250: Opened serial port device %s (handle: %d)\n", serialPortString, CR250_devHandle);
            }
            else if (*status == 1) {
                if (verbosityLevel >= 5)
                    mexPrintf("CR250: Serial port device %s is already open (handle: %d) !\n", serialPortString, CR250_devHandle);
            }
            return;
            
        // Operand: Close CR250 port 
		case CLOSE_PORT_OPERAND_ID:
            // Attempt to close the port
            *status = closeCR250Port(&CR250_devHandle);
            // Report result
            if (*status < 0) {
                mexPrintf("CR250: Failed to close serial port device (handle: %d)", CR250_devHandle);
            }
            else if (*status == 0) {
                if (verbosityLevel >= 10)
                     mexPrintf("CR250: Closed serial port device (handle: %d)\n", CR250_devHandle);
            }
            else if (*status == 1) {
                if (verbosityLevel >= 5)
                     mexPrintf("CR250: Serial port device is not open (handle: %d) !\n", CR250_devHandle);
            }
            return;
            
        
        // Operand: Update Settings
        case UPDATE_PORT_SETTINGS_OPERAND_ID:
    		// Get the passed settings
            *status = 0;
            int speed, wordSize, timeOut;
            int parity;
    		speed    = (int) mxGetScalar(prhs[1]);
    		wordSize = (int) mxGetScalar(prhs[2]);
    		parity   = (int) mxGetScalar(prhs[3]);
    		timeOut  = (int) mxGetScalar(prhs[4]);
            
    		// Set the port accordingly
    		*status = updateCR250PortSettings(&CR250_devHandle, speed, wordSize, parity,timeOut);
            
            // Report result
    		if (*status < 0) {
    			mexPrintf("CR250: Failed to update the communication settings for the serial port device (handle: %d)", CR250_devHandle);
    		}
    		else if (*status == 0) {
                if (verbosityLevel >= 10)
    			     mexPrintf("CR250: Updated the communication settings for the serial port device (handle: %d)\n", CR250_devHandle);
    		}
    		else if (*status == 1) {
                if (verbosityLevel >= 5)
    			     mexPrintf("CR250: Serial port device is not open (handle: %d)\n", CR250_devHandle);
    		}
    		return;
            
        // Operand: Read data from the port
        case READ_PORT_OPERAND_ID:
            // Check for at least 2 output arguments
    		if (nlhs < 2) {
        		mexErrMsgTxt("CR250: 'readPort' requires at least two return arguments.");
    		}
            /* Read from the port */
            *status = readCR250Port(&CR250_devHandle, &inputBuffer[0], &inputBufferSize);
            
            // Report result
    		if (*status < 0) {
    			mexErrMsgTxt("CR250: Failed to read from the serial port device\n");
    		}
    		else if (*status == 1) {
    			mexErrMsgTxt("CR250: Serial port device is not open !\n");
    		}
            else {
                char *charBuffer;
                charBuffer = mxCalloc(inputBufferSize, sizeof(char));
                for (int i = 0; i < inputBufferSize; i++)
                    charBuffer[i] = (char)inputBuffer[i];
                plhs[1] = mxCreateString(charBuffer);
                mxFree(charBuffer);
            }
            return;
            
       // Operand: Write data to the port
    	case WRITE_PORT_OPERAND_ID:
            // Check for at least 2 input arguments
    		if (nrhs < 2) {
        		mexErrMsgTxt("CR250: 'writePort' requires at least two input arguments.");
    		}
            // Check whether the second input argument is a string
            char dataToWrite[256];
			if (mxIsChar(prhs[1]) != 1) {
                *status = -1;
        		mexErrMsgTxt("CR250: Port data must be a string");
        	}
            // Get data to write
			mxGetString(prhs[1], dataToWrite, sizeof(dataToWrite));
            
    		// send command to the port
    		*status = writeCR250Port(&CR250_devHandle, (char *)dataToWrite, strlen(dataToWrite));

    		// Report result
    		if (*status < 0) {
    			mexPrintf("CR250: Failed to write command to serial port device (handle: %d)\n", CR250_devHandle);
    		}
    		else if (*status == 0) {
                if (verbosityLevel >= 10)
    			     mexPrintf("CR250: Wrote command to serial port device\n");
    		}
    		else if (*status == 1) {
    			mexPrintf("CR250: Serial port device is not open (handle: %d)\n", CR250_devHandle);
    		}
    		return;
            
            
        // Operand: Send a command
        case SEND_COMMAND_OPERAND_ID:
            // Check for at least 2 input arguments
    		if (nrhs < 2) {
        		mexErrMsgTxt("CR250: 'sendCommand' requires at least two input arguments.");
    		}
            
            // Check whether the second input argument is a string
			char commandName[256];
			if (mxIsChar(prhs[1]) != 1) {
        		mexErrMsgTxt("CR250: Command name must be a string, e.g., 'RC Model'.");
        	}
            
            // Get the command string (second input argument)
			mxGetString(prhs[1], commandName, sizeof(commandName));
            
        
            // Find commandIndex
			int commandIndex = -1;
			for (int i = 0; i < sizeof(commandDictionary)/sizeof(commandEntry); i++) {
				if (strcmp(commandName, commandDictionary[i].ID) == 0 ) {
					commandIndex = i;
					break;
				}
			} // for i
            
            if (commandIndex == -1) {
				sprintf(errorMessage, "CR250: Command name ('%s') was not recognized\n", commandName);
				mexErrMsgTxt(errorMessage);
            }
           
            if (strcmp(commandName, "SM SyncFreq") == 0) {
                // Get the frequency, in milliHz (third input argument)
                double syncFrequencyHz;
    		    syncFrequencyHz = (double)((int) mxGetScalar(prhs[2]))/(double)(1000);
                sprintf(commandName, "%s %2.2f", commandName, syncFrequencyHz);
                mexPrintf("Will send command: %s\n", commandName);
            }

            /* Simply clear the port in case there is stuff from a previous operation */
            *status = readCR250Port(&CR250_devHandle, &inputBuffer[0], &inputBufferSize);
            if (*status == -1) {
                sprintf(errorMessage, "CR250: Could not clear port\n");
				mexErrMsgTxt(errorMessage);
            }
            
            // Generate command string to be sent
			char commandBuffer[1024];
			strcpy(commandBuffer, commandName);
			size_t currentLength = strlen(commandBuffer);
			commandBuffer[currentLength]  = '\r';
			commandBuffer[currentLength+1]= '\0';
            
            // send command to the port
			*status = writeCR250Port(&CR250_devHandle, (char *)commandBuffer, strlen(commandBuffer));
            
            // Check for early termination due to failure to write
			if (*status == -1) {
				mexErrMsgTxt("CR250: Failed to write command to serial port device. Is the device open?\n");
			}
			else if (*status == 0) {
                if (verbosityLevel >= 10)
				    mexPrintf("KCR250: Succesfully wrote command '%s' to serial port device\n", commandName);
			}
			else if (*status == 1) {
				mexErrMsgTxt("CR250: Serial port device is not open !\n");
			}
            

            int commandResultsBufferLength;
            if (commandDictionary[commandIndex].charsNumToBeReturned > 0)
               commandResultsBufferLength = commandDictionary[commandIndex].charsNumToBeReturned;
            else 
               commandResultsBufferLength = 2;

             // Allocate memory for commandResults
             char *commandResultsBuffer;
             commandResultsBuffer = mxCalloc(commandResultsBufferLength, sizeof(char));

             int expectedCharsNum, timeOutSeconds, sleepTimeInMilliseconds, timedOut, bytesRead;
             expectedCharsNum = commandDictionary[commandIndex].charsNumToBeReturned;
             timeOutSeconds   = commandDictionary[commandIndex].timeOutSeconds;
             sleepTimeInMilliseconds = 50;

             // Poll the CR250
             *status = pollCR250Port(&CR250_devHandle, expectedCharsNum, timeOutSeconds, sleepTimeInMilliseconds, &timedOut, &commandResultsBuffer[0], commandResultsBufferLength, &bytesRead);
                     
             if (*status == -1) {
                mexErrMsgTxt("CR250: Failure during serial port polling\n");
             }
             else if (*status == 1) {
                mexErrMsgTxt("CR250: Serial port device is not open !\n");
             }
             if (timedOut == 1) {
                //mexErrMsgTxt("CR250: Timed out while polling the port. \n");
                mexPrintf("CR250: Timed out while polling the port. \n");
             }
             if ((bytesRead != commandResultsBufferLength) && (expectedCharsNum != -1)) {
                mexPrintf("Expected %d chars, but read %d chars instead\n", commandResultsBufferLength, bytesRead);
                if (verbosityLevel >= 5) {
                    mexPrintf("Received message: %s\n",commandResultsBuffer);
                }
             }

             // Copy the raw data
             plhs[1] = mxCreateString(commandResultsBuffer);
              
 
              // free memory since we copied it to output buffer
              mxFree(commandResultsBuffer);
            
              return;
            
            
    }  /* switch (operandID) */
           
}



/* ------------------------------------------------------------------------
 * Method to read from the serial port until a complete response is obtained or timed-out
 * Returns -1 if unsucessful,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int pollCR250Port(int *deviceHandle, int expectedCharsNum, int timeOutSeconds, int sleepTimeInMilliseconds, int *timedOut, char  *resultsBuffer, int resultsBufferLength, int *bytesRead)
{
    	*timedOut = 1;

		unsigned char inputBuffer[MAX_INPUT_BUFFER_SIZE];
    	int inputBufferSize;
    	*bytesRead = 0;

    	/* Go through 3 times */
    	int i;
    	int maxI = timeOutSeconds*1000/sleepTimeInMilliseconds;
        int resultsBufferOverrun = 0;
        
        int timeOutPass = 3;
    	while (timeOutPass > 0) {
            
        	timeOutPass--;
        	i = 0;

        	while (i < maxI) {
                /* sleep  */
                if (sleepTimeInMilliseconds > 0)
	            		usleep(sleepTimeInMilliseconds*1000);

            		if (expectedCharsNum <= 0) {
                		*timedOut = 0;
                		break;
            		}

            		/* read new data */
            		int status = readCR250Port(deviceHandle, &inputBuffer[0], &inputBufferSize);
            		if (status != 0) {
                		mexPrintf("CR250: failed to read during polling\n");
                		return(-1);
            		}
            		/* store new data */

					int j;
            		for (j = 0; j < inputBufferSize; j++) {
                        if (((*bytesRead)+j < resultsBufferLength)&&(j < MAX_INPUT_BUFFER_SIZE)) {
                            resultsBuffer[(*bytesRead)+j] = (char)inputBuffer[j];
                            }
                        else {
                            resultsBufferOverrun = 1;
                            mexPrintf("resultsBuffer over-run !!!! Trying to access element %d in array[%d] \n", (*bytesRead)+j, resultsBufferLength);
                        }
                    }
            		*bytesRead += inputBufferSize;
                    if ((*bytesRead != expectedCharsNum) && (expectedCharsNum != -1)) {
                        if (verbosityLevel >= 10) {
            		        mexPrintf("bytesRead:%d (%s) (total:%d, expected:%d)\n", inputBufferSize, inputBuffer, *bytesRead, expectedCharsNum);
                        }
                    }

            		/* Check whether more chars are to be received */
            		if (*bytesRead < expectedCharsNum)
                		++i;
            		else {
                		/* expected chars have been received. Exit nested while loops */
                		i = maxI;
                		timeOutPass = 0;
                		*timedOut = 0;
            		}
        	} /* while (i < maxI) */
    	} /* while (timeOutPass > 0) */

        if (resultsBufferOverrun == 0)
            resultsBuffer[(*bytesRead)]= '\0';
        else
            resultsBuffer[resultsBufferLength-1] = '\0';
        
    	return(0);
}           
/* ------------------------------------------------------------------------
 * Method to read from the serial port until a complete response is obtained or timed-out
 * Returns -1 if unsucessful,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int pollCR250PortUsingMethod1(int *deviceHandle, int expectedCharsNum, int timeOutSeconds, int sleepTimeInMilliseconds, int *timedOut, char  *resultsBuffer, int *bytesRead)
{
    	*timedOut = 1;

		unsigned char inputBuffer[MAX_INPUT_BUFFER_SIZE];
    	int inputBufferSize;
    	*bytesRead = 0;

    	/* Go through 3 times */
    	int timeOutPass = 3;
    	int i;
    	int maxI = timeOutSeconds*1000/sleepTimeInMilliseconds;

    	while (timeOutPass > 0) {
        	timeOutPass--;
        	i = 0;

        	while (i < maxI) {
            		/* sleep  */
                if (sleepTimeInMilliseconds > 0)
                    usleep(sleepTimeInMilliseconds*1000);

                if (expectedCharsNum <= 0) {
                		*timedOut = 0;
                		break;
            		}

                /* read new data */
            	int status = readCR250Port(deviceHandle, &inputBuffer[0], &inputBufferSize);
            	if (status != 0) {
                	printf("CR250: failed to read during polling\n");
                	return(-1);
            	}
            	/* store new data */
            	size_t currentLength = strlen(resultsBuffer);
				int j;
            	for (j = 0; j < inputBufferSize; j++) 
                	resultsBuffer[currentLength+j] = (char)inputBuffer[j];
            	resultsBuffer[currentLength+inputBufferSize]= '\0';
            	*bytesRead += inputBufferSize;

            	/* Check whether more chars are to be received */
            	if (*bytesRead < expectedCharsNum)
                	++i;
            	else {
                	/* expected chars have been received. Exit nested while loops */
                	i = maxI;
                	timeOutPass = 0;
                	*timedOut = 0;
            	}
        	} /* while (i < maxI) */
    	} /* while (timeOutPass > 0) */

    	return(0);
}


/* ------------------------------------------------------------------------
 * Method to read from the serial port
 * Returns -1 if unsucessful,
 *          1 if port has NOT been opened,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int readCR250Port(int *deviceHandle, unsigned char *inputBuffer, int *inputBufferSize)
{
	/* Check whether device has not been opened */
	if (*deviceHandle == -1) 
		return(1);

	int dataSize = 1;
	ioctl(*deviceHandle, FIONREAD, &dataSize);
	*inputBufferSize = dataSize;
    
	if (dataSize >= MAX_INPUT_BUFFER_SIZE) {
		mexPrintf("CR250: inputBuffer is too short: %d < %d\n", MAX_INPUT_BUFFER_SIZE, dataSize);
		return(-1);
	}
    
	/* initialize inputBuffer with the string termination character */
    int i;
    for (i = 0; i < dataSize; ++i) inputBuffer[i] = '\0';     

    /* fill inputBuffer */
    int dataRead;
    dataRead = read(*deviceHandle, inputBuffer, dataSize);
    if (dataRead != dataSize)
        mexPrintf("CR250: Serial port failed to read all available chars: %s (%d %d chars)\n", inputBuffer, dataRead, dataSize);
    
	return(0);
}


/* ------------------------------------------------------------------------
 * Method to write to the serial port
 * Returns -1 if unsucessful,
 *          1 if port has NOT been opened,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int writeCR250Port(int *deviceHandle, char *outputBuffer, int outputBufferSize)
{
	/* Check whether device has not been opened */
	if (*deviceHandle == -1) {
        mexPrintf("CR250: Did not write to the device because it is not open\n");
		return(1);
    }

	int status = write(*deviceHandle, outputBuffer, outputBufferSize);

	if (status != outputBufferSize)
	   	mexPrintf("CR250: Serial port wrote: %d chars; Should have written %d chars \n", status, outputBufferSize);

	if (status == -1)
		return(-1);
	else
		return(0);
}


/* ------------------------------------------------------------------------
 * Method to open the serialPort. 
 * Returns -1 if unsucessful,
 *          1 if port is ALREADY open,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int openCR250Port(char *serialPortString, int *deviceHandle)
{
	/* Check whether device is already open */
    if (verbosityLevel >= 10)
        mexPrintf("device handle before open: %d\n", *deviceHandle);
	if (*deviceHandle > 0 ) 
		return(1);

	*deviceHandle = open(serialPortString, O_RDWR | O_NOCTTY | O_NDELAY);
    if (verbosityLevel >= 10)
        mexPrintf("new device handle after opening %d\n", *deviceHandle);
    
	if (*deviceHandle == -1) {
        // failed to open port
        mexPrintf("Failed to open device '%s' \n", serialPortString);
		return(-1);
	}
	else {
		return(0);
    }
}

/* ------------------------------------------------------------------------
 * Method to close the serialPort. 
 * Returns -1 if unsucessful,
 *          1 if port has NOT been opened,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int closeCR250Port(int *deviceHandle)
{
	// Check whether device has not been opened
	if (*deviceHandle == 0) 
		return(1);
	else {
		int status = close(*deviceHandle);
		if (status == -1) {
            // failed to close, put port in error state
			*deviceHandle = -1; 
			return(-1);
		}
		else {
            // closed port sucessfully.
			*deviceHandle = 0;
			return(0);
		}
	}
}

void setBlocking (int *deviceHandle, int should_block) {
    struct termios tty;
    memset (&tty, 0, sizeof tty);
    if (tcgetattr (*deviceHandle, &tty) != 0) {
        mexPrintf("error from tggetattr");
        return;
    }

    tty.c_cc[VMIN]  = should_block ? 1 : 0;
    tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

    if (tcsetattr (*deviceHandle, TCSANOW, &tty) != 0)
        mexPrintf("error setting term attributes");
}

/* ------------------------------------------------------------------------
 * Method to update the communication settings
 * Returns -1 if unsucessful,
 *          1 if port has NOT been opened,
 *          0 otherwise
 * ------------------------------------------------------------------------
*/
int updateCR250PortSettings(int *deviceHandle, int speed, int wordSize, int parity, int timeOut)
{
	/* Check whether device has not been opened */
	if (*deviceHandle== -1) 
		return(1);

	struct termios options;
    int retVal = tcgetattr(*deviceHandle, &options);
    if (retVal != 0) {
        mexPrintf("Failed to getCR250Settings. retVal is %d\n", retVal);
        return -1;
    }

    	
    // Word size
    options.c_cflag = (options.c_cflag & ~CSIZE);
    switch(wordSize) {
        case 5:
            options.c_cflag |= CS5;
            break;
        case 6:
            options.c_cflag |= CS6;
            break;
        case 7:
            options.c_cflag |= CS7;
            break;
        case 8:
        default:
            options.c_cflag |= CS8;
            break;
    } /* switch wordSize */

    // Set the in and out speed
    speed_t speedT;
    	switch(speed) {
        case 0:
            speedT = B0;
            break;
        case 50:
            speedT = B50;
            break;
        case 75:
            speedT = B75;
            break;
        case 110:
            speedT = B110;
            break;
        case 200:
            speedT = B200;
            break;
        case 300:
            speedT = B300;
            break;
        case 600:
            speedT = B600;
            break;
        case 1200:
            speedT = B1200;
            break;
        case 1800:
            speedT = B1800;
            break;
        case 2400:
            speedT = B2400;
            break;
        case 4800:
            speedT = B4800;
            break;
        case 9600:
            speedT = B9600;
            break;
        case 19200:
            speedT = B19200;
            break;
        case 38400:
            speedT = B38400;
            break;
        default:
            speedT = B19200;
            break;
    	} /* switch */

    cfsetispeed(&options, speedT);
    cfsetospeed(&options, speedT);


    // disable IGNBRK for mismatched speed tests; otherwise receive break
    // as \000 chars
    options.c_iflag &= ~IGNBRK;         // disable break processing
    options.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
    options.c_oflag = 0;                // no remapping, no delays
    options.c_cc[VMIN]  = 0;            // read doesn't block
    options.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

    options.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

    options.c_cflag |= (CLOCAL | CREAD);         // ignore modem controls,
                                                 // enable reading
    options.c_cflag &= ~(PARENB | PARODD);       // shut off parity
    options.c_cflag |= parity;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CRTSCTS;

    retVal = tcsetattr (*deviceHandle, TCSANOW, &options);

    if (retVal != 0) {
        mexPrintf("Failed to updateCR250Settings. retVal is %d\n", retVal);
        return -1;
    }

    //setBlocking(deviceHandle, 0);                // set no blocking
    setBlocking(deviceHandle, 1);                // set yes blocking
    return (0);
}




/* Return 1 if the difference is negative, otherwise 0.  */
int timeval_subtract(struct timeval *result, struct timeval *t2, struct timeval *t1)
{
    long int diff = (t2->tv_usec + 1000000 * t2->tv_sec) - (t1->tv_usec + 1000000 * t1->tv_sec);
    result->tv_sec = diff / 1000000;
    result->tv_usec = diff % 1000000;

    return (diff<0);
}

void timeval_print(struct timeval *tv)
{
    char buffer[30];
    time_t curtime;

    //printf("%ld.%06d", tv->tv_sec, tv->tv_usec);
    curtime = tv->tv_sec;
    strftime(buffer, 30, "%m-%d-%Y  %T", localtime(&curtime));
    //printf(" = %s.%0d\n", buffer, tv->tv_usec);
}
