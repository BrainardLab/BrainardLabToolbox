#include "u6.h"
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
#include "mex.h"
#include "matrix.h"

#define OPERAND_NAME_LENGTH    32

// -- DO NOT CHANGE THESE --
const float samplingFrequencyHz = 1000;
const int resolutionIndex = 1;      //ResolutionIndex  1 = 50K / number of channels, 5 channels so 1 KHz/channel 
const uint8 NumChannels = 5;        //For this example to work proper, SamplesPerPacket needs
                                    //to be a multiple of NumChannels.
const uint8 SamplesPerPacket = 25;  //Needs to be 25 to read multiple StreamData responses
                                    //in one large packet, otherwise can be any value between
                                    //1-25 for 1 StreamData response per packet.
// ------------------------

static HANDLE hDevice;
u6CalibrationInfo caliInfo;
int isDAC1Enabled;

int configIO(HANDLE hDevice);
int streamConfig(HANDLE hDevice);
int streamStart(HANDLE hDevice);
int streamData(HANDLE hDevice, u6CalibrationInfo *caliInfo, double recordingDurationSeconds, double*voltages);
int streamStop(HANDLE hDevice);

int amU6device();
int openU6device();
int closeU6device();
int measure(double *measData, double recordingDurationSeconds);

void mexFunction(int nlhs,      /* number of output (return) arguments */
      mxArray *plhs[],          /* pointer to an array which will hold the output data, each element is of type: mxArray */
      int nrhs,                 /* number of input arguments */
      const mxArray *prhs[]     /* pointer to an array which holds the input data, each element is of type: const mxArray */
      )
{

	/* Create an 1x1 array of unsigned 32-bit integer to store the status  */
    /* This will be the first output argument */
    const int dims[] = {1, 1};
    int nDims = 2;
    plhs[0] = mxCreateNumericArray(nDims, dims, mxINT32_CLASS, mxREAL);
    int *status;
    status = (int *) mxGetData(plhs[0]);
    
    // Check for at least 1 input argument
    if (nrhs < 1) {
        mexErrMsgTxt("LJU6: Requires at least one input argument.");
    }
    
    // Get the first input argument (operand name)
    char operandName[OPERAND_NAME_LENGTH];
    if (mxIsChar(prhs[0]) != 1)
        mexErrMsgTxt("LJU6: First argument must be an operation string.");
	else
		mxGetString(prhs[0], operandName, sizeof(operandName));
    
    //printf("Operand name: %s\n", operandName);
   

    if (strcmp(operandName, "identify")==0) {
        *status = amU6device();
    }
    else if (strcmp(operandName, "open")==0) {
        *status = openU6device();
    }
    else if (strcmp(operandName, "close")==0) {
        *status = closeU6device();
    }
    else if (strcmp(operandName, "measure")==0) {
        
        double recordingDurationSeconds = mxGetScalar(prhs[1]);
        int timeSamples = (int)(recordingDurationSeconds * samplingFrequencyHz);
        // printf("Recording duration: %2.2f seconds\n", recordingDurationSeconds);
                
        // Create matrix for second output (uncorrected Ydata) 
        int mrows, ncols;
        mrows = timeSamples; 
        ncols = NumChannels;
        plhs[1] = mxCreateDoubleMatrix(mrows, ncols, mxREAL);
                
        // Create a C pointer to a copy of the measData  
        double *measData;
        measData = mxGetPr(plhs[1]);
                
        // Measure!
        *status = measure(measData, recordingDurationSeconds);
    }
    else  {
        printf("Unknown command name, %s", operandName);
    }
}

int measure(double *measData, double recordingDurationSeconds)
{
    //Stopping any previous streams
    if (streamStop(hDevice) != 0) {
    	//printf ("StreamStop failed before starting to stream.\n");
        //return 0;
    }
            
    if( streamConfig(hDevice) != 0 ) {
        printf ("StreamConfig failed\n");
        return 0;
    }
    
    if( streamStart(hDevice) != 0 ) {
        printf ("StreamStart failed\n");
        return 0;
    }

    // Get the data
    streamData(hDevice, &caliInfo, recordingDurationSeconds, measData);
    
    if (streamStop(hDevice) != 0) {
        printf ("StreamStop failed after data streaming.\n");
        return 0;
    }
                
    return 1;
}


int amU6device()
{
    
    printf("Checking for U6 to be connected... \n");
    
    // Check for U6 connected
    if(LJUSB_GetDevCount(U6_PRODUCT_ID)) {
        printf("Found U6 device!\n");
        return 1;
    }
    else { 
        printf ("No U6 Labjack found\n");
        return 0;
    }
}


int openU6device() 
{
  
    if ( (hDevice = openUSBConnection(-1)) == NULL) {
        return 0;  // could not open device
    }
    
    //Getting calibration information from U3
    if( getCalibrationInfo(hDevice, &caliInfo) < 0 ) {
        return 0;  // could not get calibration data
    }

    if(configIO(hDevice) != 0 ) {
        return 0;
    }
    
    // Success opening the device 
    return 1;
   
}

int closeU6device() 
{
    if (hDevice != NULL) {
        closeUSBConnection(hDevice);
        hDevice = NULL;
    }
    else {
        //mexPrintf("U6 device was not open.\n");
    }
    return(1); 
}

//Sends a ConfigIO low-level command to turn off timers/counters
int configIO(HANDLE hDevice)
{
    uint8 sendBuff[16], recBuff[16];
    uint16 checksumTotal;
    int sendChars, recChars, i;

    sendBuff[1] = (uint8)(0xF8);  //Command byte
    sendBuff[2] = (uint8)(0x03);  //Number of data words
    sendBuff[3] = (uint8)(0x0B);  //Extended command number

    sendBuff[6] = 1;  //Writemask : Setting writemask for TimerCounterConfig (bit 0)

    sendBuff[7] = 0;  //NumberTimersEnabled : Setting to zero to disable all timers.
    sendBuff[8] = 0;  //CounterEnable: Setting bit 0 and bit 1 to zero to disable both counters
    sendBuff[9] = 0;  //TimerCounterPinOffset

    for( i = 10; i < 16; i++ )
        sendBuff[i] = 0;   //Reserved
    extendedChecksum(sendBuff, 16);

    //Sending command to U6
    if( (sendChars = LJUSB_Write(hDevice, sendBuff, 16)) < 16 )
    {
        if( sendChars == 0 )
            printf("ConfigIO error : write failed\n");
        else
            printf("ConfigIO error : did not write all of the buffer\n");
        return -1;
    }

    //Reading response from U6
    if( (recChars = LJUSB_Read(hDevice, recBuff, 16)) < 16 )
    {
        if( recChars == 0 )
            printf("ConfigIO error : read failed\n");
        else
            printf("ConfigIO error : did not read all of the buffer\n");
        return -1;
    }

    checksumTotal = extendedChecksum16(recBuff, 15);
    if( (uint8)((checksumTotal / 256 ) & 0xff) != recBuff[5] )
    {
        printf("ConfigIO error : read buffer has bad checksum16(MSB)\n");
        return -1;
    }

    if( (uint8)(checksumTotal & 0xff) != recBuff[4] )
    {
        printf("ConfigIO error : read buffer has bad checksum16(LSB)\n");
        return -1;
    }

    if( extendedChecksum8(recBuff) != recBuff[0] )
    {
        printf("ConfigIO error : read buffer has bad checksum8\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x05) || recBuff[3] != (uint8)(0x0B) )
    {
        printf("ConfigIO error : read buffer has wrong command bytes\n");
        return -1;
    }

    if( recBuff[6] != 0 )
    {
        printf("ConfigIO error : read buffer received errorcode %d\n", recBuff[6]);
        return -1;
    }

    if( recBuff[8] != 0 )
    {
        printf("ConfigIO error : NumberTimersEnabled was not set to 0\n");
        return -1;
    }

    if( recBuff[9] != 0 )
    {
        printf("ConfigIO error : CounterEnable was not set to 0\n");
        return -1;
    }

    return 0;
}


//Sends a streamConfig low-level command to configure the stream.
int streamConfig(HANDLE hDevice)
{
    int sendBuffSize;
    sendBuffSize = 14+NumChannels*2;
    uint8 sendBuff[sendBuffSize], recBuff[8];
    int sendChars, recChars;
    uint16 checksumTotal;
    uint16 scanInterval;
    int i;

    sendBuff[1] = (uint8)(0xF8);     //Command byte
    sendBuff[2] = 4 + NumChannels;   //Number of data words = NumChannels + 4
    sendBuff[3] = (uint8)(0x11);     //Extended command number
    sendBuff[6] = NumChannels;       //NumChannels
    sendBuff[7] = resolutionIndex;   //ResolutionIndex  1 = 50K / number of channels, 5 channels so 1 KHz/channel         
    sendBuff[8] = SamplesPerPacket;  //SamplesPerPacket
    sendBuff[9] = 0;                 //Reserved
    sendBuff[10] = 0;                //SettlingFactor: 0
    sendBuff[11] = 0;  //ScanConfig:
                       //  Bit 3: Internal stream clock frequency = b0: 4 MHz
                       //  Bit 1: Divide Clock by 256 = b0

    scanInterval = 4000;
    sendBuff[12] = (uint8)(scanInterval&(0x00FF));  //scan interval (low byte)
    sendBuff[13] = (uint8)(scanInterval/256);       //scan interval (high byte)

    for( i = 0; i < NumChannels; i++ )
    {
        sendBuff[14 + i*2] = i;  //ChannelNumber (Positive) = i
        sendBuff[15 + i*2] = 0;  //ChannelOptions: 
                                 //  Bit 7: Differential = 0
                                 //  Bit 5-4: GainIndex = 0 (+-10V)
    }

    extendedChecksum(sendBuff, sendBuffSize);

    //Sending command to U6
    sendChars = LJUSB_Write(hDevice, sendBuff, sendBuffSize);
    if( sendChars < sendBuffSize )
    {
        if( sendChars == 0 )
            printf("Error : write failed (StreamConfig).\n");
        else
            printf("Error : did not write all of the buffer (StreamConfig).\n");
        return -1;
    }

    for( i = 0; i < 8; i++ )
        recBuff[i] = 0;

    //Reading response from U6
    recChars = LJUSB_Read(hDevice, recBuff, 8);
    if( recChars < 8 )
    {
        if( recChars == 0 )
            printf("Error : read failed (StreamConfig).\n");
        else
            printf("Error : did not read all of the buffer, %d (StreamConfig).\n", recChars);

        for( i = 0; i < 8; i++)
            printf("%d ", recBuff[i]);

        return -1;
    }

    checksumTotal = extendedChecksum16(recBuff, 8);
    if( (uint8)((checksumTotal / 256) & 0xff) != recBuff[5])
    {
        printf("Error : read buffer has bad checksum16(MSB) (StreamConfig).\n");
        return -1;
    }

    if( (uint8)(checksumTotal & 0xff) != recBuff[4] )
    {
        printf("Error : read buffer has bad checksum16(LSB) (StreamConfig).\n");
        return -1;
    }

    if( extendedChecksum8(recBuff) != recBuff[0] )
    {
        printf("Error : read buffer has bad checksum8 (StreamConfig).\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x01) || recBuff[3] != (uint8)(0x11) || recBuff[7] != (uint8)(0x00) )
    {
        printf("Error : read buffer has wrong command bytes (StreamConfig).\n");
        return -1;
    }

    if( recBuff[6] != 0 )
    {
        printf("Errorcode # %d from StreamConfig read.\n", (unsigned int)recBuff[6]);
        return -1;
    }

    return 0;
}

//Sends a StreamStart low-level command to start streaming.
int streamStart(HANDLE hDevice)
{
    uint8 sendBuff[2], recBuff[4];
    int sendChars, recChars;

    sendBuff[0] = (uint8)(0xA8);  //Checksum8
    sendBuff[1] = (uint8)(0xA8);  //Command byte

    //Sending command to U6
    sendChars = LJUSB_Write(hDevice, sendBuff, 2);
    if( sendChars < 2 )
    {
        if( sendChars == 0 )
            printf("Error : write failed.\n");
        else
            printf("Error : did not write all of the buffer.\n");
        return -1;
    }

    //Reading response from U6
    recChars = LJUSB_Read(hDevice, recBuff, 4);
    if( recChars < 4 )
    {
        if( recChars == 0 )
            printf("Error : read failed.\n");
        else
            printf("Error : did not read all of the buffer.\n");
        return -1;
    }

    if( normalChecksum8(recBuff, 4) != recBuff[0] )
    {
        printf("Error : read buffer has bad checksum8 (StreamStart).\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xA9) || recBuff[3] != (uint8)(0x00) )
    {
        printf("Error : read buffer has wrong command bytes \n");
        return -1;
    }

    if( recBuff[2] != 0 )
    {
        printf("Errorcode # %d from StreamStart read.\n", (unsigned int)recBuff[2]);
        return -1;
    }

    return 0;
}

//Reads the StreamData low-level function response in a loop.
//All voltages from the stream are stored in the voltages 2D array.
int streamData(HANDLE hDevice, u6CalibrationInfo *caliInfo, double recordingDurationSeconds, double *measData)
{
    int recBuffSize;
    recBuffSize = 14 + SamplesPerPacket*2;
    int recChars, backLog;
    int i, j, k, m, packetCounter, currChannel, scanNumber;
    int totalPackets;  //The total number of StreamData responses read
    uint16 voltageBytes, checksumTotal;
    long startTime, endTime;
    int autoRecoveryOn;

    int numDisplay;          //Number of times to display streaming information
    int numReadsPerDisplay;  //Number of packets to read before displaying streaming information
    int readSizeMultiplier;  //Multiplier for the StreamData receive buffer size
    int responseSize;        //The number of bytes in a StreamData response (differs with SamplesPerPacket)

    numReadsPerDisplay = 1;
    readSizeMultiplier = 5;
    numDisplay = (int)(1000.0 * recordingDurationSeconds / (float)(numReadsPerDisplay*readSizeMultiplier * (float)(SamplesPerPacket / NumChannels)));  // 6
    responseSize = 14 + SamplesPerPacket*2;

    /* Each StreamData response contains (SamplesPerPacket / NumChannels) * readSizeMultiplier
     * samples for each channel.
     * Total number of scans = (SamplesPerPacket / NumChannels) * readSizeMultiplier * numReadsPerDisplay * numDisplay
     */
    int timeSamples = (SamplesPerPacket/NumChannels)*readSizeMultiplier*numReadsPerDisplay*numDisplay;
    //double voltages[timeSamples][NumChannels];
    //printf("voltages: %d x %d\n", (SamplesPerPacket/NumChannels)*readSizeMultiplier*numReadsPerDisplay*numDisplay, NumChannels);
    
    uint8 recBuff[responseSize*readSizeMultiplier];
    packetCounter = 0;
    currChannel = 0;
    scanNumber = 0;
    totalPackets = 0;
    recChars = 0;
    autoRecoveryOn = 0;

    printf("Reading Samples...\n");

    startTime = getTickCount();

    for( i = 0; i < numDisplay; i++ )
    {
        for( j = 0; j < numReadsPerDisplay; j++ )
        {
            /* For USB StreamData, use Endpoint 3 for reads.  You can read the multiple
             * StreamData responses of 64 bytes only if SamplesPerPacket is 25 to help
             * improve streaming performance.  In this example this multiple is adjusted
             * by the readSizeMultiplier variable.
             */

            //Reading stream response from U6
            recChars = LJUSB_Stream(hDevice, recBuff, responseSize*readSizeMultiplier);
            if( recChars < responseSize*readSizeMultiplier )
            {
                if(recChars == 0)
                    printf("Error : read failed (StreamData).\n");
                else
                    printf("Error : did not read all of the buffer, expected %d bytes but received %d(StreamData).\n", responseSize*readSizeMultiplier, recChars);

                return -1;
            }

            //Checking for errors and getting data out of each StreamData response
            for( m = 0; m < readSizeMultiplier; m++ )
            {
                totalPackets++;

                checksumTotal = extendedChecksum16(recBuff + m*recBuffSize, recBuffSize);
                if( (uint8)((checksumTotal >> 8) & 0xff) != recBuff[m*recBuffSize + 5] )
                {
                    printf("Error : read buffer has bad checksum16(MSB) (StreamData).\n");
                    return -1;
                }

                if( (uint8)(checksumTotal & 0xff) != recBuff[m*recBuffSize + 4] )
                {
                    printf("Error : read buffer has bad checksum16(LSB) (StreamData).\n");
                    return -1;
                }

                checksumTotal = extendedChecksum8(recBuff + m*recBuffSize);
                if( checksumTotal != recBuff[m*recBuffSize] )
                {
                    printf("Error : read buffer has bad checksum8 (StreamData).\n");
                    return -1;
                }

                if( recBuff[m*recBuffSize + 1] != (uint8)(0xF9) || recBuff[m*recBuffSize + 2] != 4 + SamplesPerPacket || recBuff[m*recBuffSize + 3] != (uint8)(0xC0) )
                {
                    printf("Error : read buffer has wrong command bytes (StreamData).\n");
                    return -1;
                }

                if( recBuff[m*recBuffSize + 11] == 59 )
                {
                    if( !autoRecoveryOn )
                    {
                        printf("\nU6 data buffer overflow detected in packet %d.\nNow using auto-recovery and reading buffered samples.\n", totalPackets);
                        autoRecoveryOn = 1;
                    }
                }
                else if( recBuff[m*recBuffSize + 11] == 60 )
                {
                    printf("Auto-recovery report in packet %d: %d scans were dropped.\nAuto-recovery is now off.\n", totalPackets, recBuff[m*recBuffSize + 6] + recBuff[m*recBuffSize + 7]*256);
                    autoRecoveryOn = 0;
                }
                else if( recBuff[m*recBuffSize + 11] != 0 )
                {
                    printf("Errorcode # %d from StreamData read.\n", (unsigned int)recBuff[11]);
                    return -1;
                }

                if( packetCounter != (int)recBuff[m*recBuffSize + 10] )
                {
                    printf("PacketCounter (%d) does not match with with current packet count (%d)(StreamData).\n", recBuff[m*recBuffSize + 10], packetCounter);
                    return -1;
                }

                backLog = (int)recBuff[m*48 + 12 + SamplesPerPacket*2];

                for( k = 12; k < (12 + SamplesPerPacket*2); k += 2 )
                {
                    voltageBytes = (uint16)recBuff[m*recBuffSize + k] + (uint16)recBuff[m*recBuffSize + k+1]*256;

                    //getAinVoltCalibrated(caliInfo, 1, 0, 0, voltageBytes, &(voltages[scanNumber][currChannel]));
                    getAinVoltCalibrated(caliInfo, 1, 0, 0, voltageBytes, &(measData[scanNumber+currChannel*timeSamples]));
                    
                    currChannel++;
                    if( currChannel >= NumChannels )
                    {
                        currChannel = 0;
                        scanNumber++;
                    }
                }

                if(packetCounter >= 255)
                    packetCounter = 0;
                else
                    packetCounter++;
            }
        }

        /*
        printf("\nNumber of scans: %d\n", scanNumber);
        printf("Total packets read: %d\n", totalPackets);
        printf("Current PacketCounter: %d\n", ((packetCounter == 0) ? 255 : packetCounter-1));
        printf("Current BackLog: %d\n", backLog);
        
        
        for( k = 0; k < NumChannels; k++ )
            printf("  AI%d: %.4f V\n", k, voltages[scanNumber - 1][k]);
        */
    }

    endTime = getTickCount();
    /*
    printf("\nRate of samples: %.0lf samples per second\n", (scanNumber*NumChannels)/((endTime - startTime)/1000.0));
    printf("Rate of scans: %.0lf scans per second\n\n", scanNumber/((endTime - startTime)/1000.0));
    */
    //memcpy(measData, voltages, sizeof(voltages[0])*timeSamples*NumChannels);
    
//     for(int i = 0; i<timeSamples; i++)
//     {
//         memcpy(&measData[i], &voltages[i], sizeof(voltages[0]));
//     }
    return 0;
}


//Sends a StreamStop low-level command to stop streaming.
int streamStop(HANDLE hDevice)
{
    uint8 sendBuff[2], recBuff[4];
    int sendChars, recChars;

    sendBuff[0] = (uint8)(0xB0);  //Checksum8
    sendBuff[1] = (uint8)(0xB0);  //Command byte

    //Sending command to U6
    sendChars = LJUSB_Write(hDevice, sendBuff, 2);
    if( sendChars < 2 )
    {
        if( sendChars == 0 )
            printf("Error : write failed (StreamStop).\n");
        else
            printf("Error : did not write all of the buffer (StreamStop).\n");
        return -1;
    }

    //Reading response from U6
    recChars = LJUSB_Read(hDevice, recBuff, 4);
    if( recChars < 4 )
    {
        if( recChars == 0 )
            printf("Error : read failed (StreamStop).\n");
        else
            printf("Error : did not read all of the buffer (StreamStop).\n");
        return -1;
    }

    if( normalChecksum8(recBuff, 4) != recBuff[0] )
    {
        printf("Error : read buffer has bad checksum8 (StreamStop).\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xB1) || recBuff[3] != (uint8)(0x00) )
    {
        printf("Error : read buffer has wrong command bytes (StreamStop).\n");
        return -1;
    }

    if( recBuff[2] != 0 )
    {
        printf("Errorcode # %d from StreamStop read.\n", (unsigned int)recBuff[2]);
        return -1;
    }

    return 0;
}

u6CalibrationInfo U6_CALIBRATION_INFO_DEFAULT = {
    6,
    1,
    //Nominal Values
    {0.00031580578,
    -10.5869565220,
    0.000031580578,
    -1.05869565220,
    0.0000031580578,
    -0.105869565220,
    0.00000031580578,
    -0.0105869565220,
    -.000315805800,
    33523.0,
    -.0000315805800,
    33523.0,
    -.00000315805800,
    33523.0,
    -.000000315805800,
    33523.0,
    13200.0,
    0.0,
    13200.0,
    0.0,
    0.00001,
    0.0002,
    -92.379,
    465.129,
    0.00031580578,
    -10.5869565220,
    0.000031580578,
    -1.05869565220,
    0.0000031580578,
    -0.105869565220,
    0.00000031580578,
    -0.0105869565220,
    -.000315805800,
    33523.0,
    -.0000315805800,
    33523.0,
    -.00000315805800,
    33523.0,
    -.000000315805800,
    33523.0}
};

void normalChecksum(uint8 *b, int n)
{
    b[0] = normalChecksum8(b,n);
}


void extendedChecksum(uint8 *b, int n)
{
    uint16 a;

    a = extendedChecksum16(b,n);
    b[4] = (uint8)(a & 0xff);
    b[5] = (uint8)((a/256) & 0xff);
    b[0] = extendedChecksum8(b);
}


uint8 normalChecksum8(uint8 *b, int n)
{
    int i;
    uint16 a, bb;

    //Sums bytes 1 to n-1 unsigned to a 2 byte value. Sums quotient and
    //remainder of 256 division.  Again, sums quotient and remainder of
    //256 division.
    for( i = 1, a = 0; i < n; i++ )
        a += (uint16)b[i];

    bb = a/256;
    a = (a-256*bb)+bb;
    bb = a/256;

    return (uint8)((a-256*bb)+bb);
}


uint16 extendedChecksum16(uint8 *b, int n)
{
    int i, a = 0;

    //Sums bytes 6 to n-1 to a unsigned 2 byte value
    for( i = 6; i < n; i++ )
        a += (uint16)b[i];

    return a;
}


uint8 extendedChecksum8(uint8 *b)
{
    int i, a, bb;

    //Sums bytes 1 to 5. Sums quotient and remainder of 256 division. Again, sums
    //quotient and remainder of 256 division.
    for( i = 1, a = 0; i < 6; i++ )
        a += (uint16)b[i];

    bb = a/256;
    a = (a-256*bb)+bb;
    bb = a/256;

    return (uint8)((a-256*bb)+bb);
}


HANDLE openUSBConnection(int localID)
{
    BYTE sendBuffer[26], recBuffer[38];
    uint16 checksumTotal = 0;
    uint32 dev, numDevices = 0;
    int i;
    HANDLE hDevice = 0;

    numDevices = LJUSB_GetDevCount(U6_PRODUCT_ID);
    if( numDevices == 0 )
    {
        printf("Open error: No U6 devices could be found\n");
        return NULL;
    }

    for( dev = 1;  dev <= numDevices; dev++ )
    {
        hDevice = LJUSB_OpenDevice(dev, 0, U6_PRODUCT_ID);
        if( hDevice != NULL )
        {
            if( localID < 0 )
            {
                return hDevice;
            }
            else
            {
                checksumTotal = 0;

                //setting up a U6Config
                sendBuffer[1] = (uint8)(0xF8);
                sendBuffer[2] = (uint8)(0x0A);
                sendBuffer[3] = (uint8)(0x08);

                for( i = 6; i < 26; i++ )
                    sendBuffer[i] = (uint8)(0x00);

                extendedChecksum(sendBuffer, 26);

                if( LJUSB_Write(hDevice, sendBuffer, 26) != 26 )
                    goto locid_error;

                if( LJUSB_Read(hDevice, recBuffer, 38) != 38 )
                    goto locid_error;

                checksumTotal = extendedChecksum16(recBuffer, 38);
                if( (uint8)((checksumTotal / 256) & 0xff) != recBuffer[5] )
                    goto locid_error;

                if( (uint8)(checksumTotal & 0xff) != recBuffer[4] )
                    goto locid_error;

                if( extendedChecksum8(recBuffer) != recBuffer[0] )
                    goto locid_error;

                if( recBuffer[1] != (uint8)(0xF8) || recBuffer[2] != (uint8)(0x10) ||
                    recBuffer[3] != (uint8)(0x08) )
                    goto locid_error;

                if( recBuffer[6] != 0 )
                    goto locid_error;

                //Check locasl ID and serial number
                if( (int)recBuffer[21] == localID ||
                    (int)(recBuffer[15] + recBuffer[16]*256 + recBuffer[17]*65536 + recBuffer[18]*16777216) == localID )
                    return hDevice;

                //No matches, not our device
                LJUSB_CloseDevice(hDevice);
            }  //else localID >= 0 end
        }  //if hDevice != NULL end
    }  //for end

    printf("Open error: could not find a U6 with a local ID or serial number of %d\n", localID);
    return NULL;

locid_error:
    printf("Open error: problem when checking local ID\n");
    return NULL;
}


void closeUSBConnection(HANDLE hDevice)
{
    LJUSB_CloseDevice(hDevice);
}


long getTickCount()
{
    struct timeval tv;

    gettimeofday(&tv, NULL);

    return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
}


long isCalibrationInfoValid(u6CalibrationInfo *caliInfo)
{
    if( caliInfo == NULL )
        goto invalid;
    if( caliInfo->prodID != 6 )
        goto invalid;

    return 1;
invalid:
    printf("Error: Invalid calibration info.\n");
    return 0;
}


long isTdacCalibrationInfoValid(u6TdacCalibrationInfo *caliInfo)
{
    if( caliInfo == NULL )
        goto invalid;
    if( caliInfo->prodID != 6 )
        goto invalid;
    return 1;
invalid:
    printf("Error: Invalid LJTDAC calibration info.\n");
    return 0;
}


long getCalibrationInfo(HANDLE hDevice, u6CalibrationInfo *caliInfo)
{
    uint8 sendBuffer[64], recBuffer[64];
    int sentRec = 0, offset = 0, i = 0;

    /* sending ConfigU6 command to get see if hi res */
    sendBuffer[1] = (uint8)(0xF8);  //command byte
    sendBuffer[2] = (uint8)(0x0A);  //number of data words
    sendBuffer[3] = (uint8)(0x08);  //extended command number

    //setting WriteMask0 and all other bytes to 0 since we only want to read the response
    for( i = 6; i < 26; i++ )
        sendBuffer[i] = 0;

    extendedChecksum(sendBuffer, 26);

    sentRec = LJUSB_Write(hDevice, sendBuffer, 26);
    if( sentRec < 26 )
    {
        if( sentRec == 0 )
            goto writeError0;
        else
            goto writeError1;
    }

    sentRec = LJUSB_Read(hDevice, recBuffer, 38);
    if( sentRec < 38 )
    {
        if( sentRec == 0 )
            goto readError0;
        else
            goto readError1;
    }

    if( recBuffer[1] != (uint8)(0xF8) || recBuffer[2] != (uint8)(0x10) || recBuffer[3] != (uint8)(0x08) )
        goto commandByteError;

    caliInfo->hiRes = (((recBuffer[37]&8) == 8)?1:0);

    for( i = 0; i < 10; i++ )
    {
        /* reading block i from memory */
        sendBuffer[1] = (uint8)(0xF8);  //command byte
        sendBuffer[2] = (uint8)(0x01);  //number of data words
        sendBuffer[3] = (uint8)(0x2D);  //extended command number
        sendBuffer[6] = 0;
        sendBuffer[7] = (uint8)i;       //Blocknum = i
        extendedChecksum(sendBuffer, 8);

        sentRec = LJUSB_Write(hDevice, sendBuffer, 8);
        if( sentRec < 8 )
        {
            if( sentRec == 0 )
                goto writeError0;
            else
                goto writeError1;
        }

        sentRec = LJUSB_Read(hDevice, recBuffer, 40);
        if( sentRec < 40 )
        {
            if( sentRec == 0 )
                goto readError0;
            else
                goto readError1;
        }

        if( recBuffer[1] != (uint8)(0xF8) || recBuffer[2] != (uint8)(0x11) || recBuffer[3] != (uint8)(0x2D) )
            goto commandByteError;

        offset = i*4;

        //block data starts on byte 8 of the buffer
        caliInfo->ccConstants[offset] = FPuint8ArrayToFPDouble(recBuffer + 8, 0);
        caliInfo->ccConstants[offset + 1] = FPuint8ArrayToFPDouble(recBuffer + 8, 8);
        caliInfo->ccConstants[offset + 2] = FPuint8ArrayToFPDouble(recBuffer + 8, 16);
        caliInfo->ccConstants[offset + 3] = FPuint8ArrayToFPDouble(recBuffer + 8, 24);
    }

    caliInfo->prodID = 6;

    return 0;

writeError0:
    printf("Error : getCalibrationInfo write failed\n");
    return -1;

writeError1:
    printf("Error : getCalibrationInfo did not write all of the buffer\n");
    return -1;

readError0:
    printf("Error : getCalibrationInfo read failed\n");
    return -1;

readError1:
    printf("Error : getCalibrationInfo did not read all of the buffer\n");
    return -1;

commandByteError:
    printf("Error : getCalibrationInfo received wrong command bytes for ReadMem\n");
    return -1;
}


long getTdacCalibrationInfo(HANDLE hDevice, u6TdacCalibrationInfo *caliInfo, uint8 DIOAPinNum)
{
    int err;
    uint8 options, speedAdjust, sdaPinNum, sclPinNum;
    uint8 address, numByteToSend, numBytesToReceive, errorcode;
    uint8 bytesCommand[1], bytesResponse[32], ackArray[4];

    err = 0;

    //Setting up I2C command for LJTDAC
    options = 0;               //I2COptions : 0
    speedAdjust = 0;           //SpeedAdjust : 0 (for max communication speed of about 130 kHz)
    sdaPinNum = DIOAPinNum+1;  //SDAPinNum : FIO channel connected to pin DIOB
    sclPinNum = DIOAPinNum;    //SCLPinNum : FIO channel connected to pin DIOA
    address = (uint8)(0xA0);   //Address : h0xA0 is the address for EEPROM
    numByteToSend = 1;         //NumI2CByteToSend : 1 byte for the EEPROM address
    numBytesToReceive = 32;    //NumI2CBytesToReceive : getting 32 bytes starting at EEPROM address specified in I2CByte0

    bytesCommand[0] = 64;       //I2CByte0 : Memory Address (starting at address 64 (DACA Slope)

    //Performing I2C low-level call
    err = I2C(hDevice, options, speedAdjust, sdaPinNum, sclPinNum, address, numByteToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

    if( errorcode != 0 )
    {
        printf("Getting LJTDAC calibration info error : received errorcode %d in response\n", errorcode);
        err = -1;
    }

    if( err == -1 )
        return err;

    caliInfo->ccConstants[0] = FPuint8ArrayToFPDouble(bytesResponse, 0);
    caliInfo->ccConstants[1] = FPuint8ArrayToFPDouble(bytesResponse, 8);
    caliInfo->ccConstants[2] = FPuint8ArrayToFPDouble(bytesResponse, 16);
    caliInfo->ccConstants[3] = FPuint8ArrayToFPDouble(bytesResponse, 24);
    caliInfo->prodID = 6;

    return err;
}


double FPuint8ArrayToFPDouble(uint8 *buffer, int startIndex)
{
    uint32 resultDec = 0, resultWh = 0;

    resultDec = (uint32)buffer[startIndex] |
                ((uint32)buffer[startIndex + 1] << 8) |
                ((uint32)buffer[startIndex + 2] << 16) |
                ((uint32)buffer[startIndex + 3] << 24);

    resultWh = (uint32)buffer[startIndex + 4] |
                ((uint32)buffer[startIndex + 5] << 8) |
                ((uint32)buffer[startIndex + 6] << 16) |
                ((uint32)buffer[startIndex + 7] << 24);

    return ( (double)((int)resultWh) + (double)(resultDec)/4294967296.0 );
}


long getAinVoltCalibrated(u6CalibrationInfo *caliInfo, int resolutionIndex, int gainIndex, int bits24, uint32 bytesVolt, double *analogVolt)
{
    double value = 0;
    int indexAdjust = 0;

    if( isCalibrationInfoValid(caliInfo) == 0 )
        return -1;

    value = (double)bytesVolt;
    if( bits24)
        value = value/256.0;

    if( gainIndex > 4 )
    {
        printf("getAinVoltCalibrated error: invalid gain index.\n");
        return -1;
    }
    if( resolutionIndex > 8 )
        indexAdjust = 24;

    if( value < caliInfo->ccConstants[indexAdjust + gainIndex*2 + 9] )
        *analogVolt = (caliInfo->ccConstants[indexAdjust + gainIndex*2 + 9] - value) * caliInfo->ccConstants[indexAdjust + gainIndex*2 + 8];
    else
        *analogVolt = (value - caliInfo->ccConstants[indexAdjust + gainIndex*2 + 9]) * caliInfo->ccConstants[indexAdjust + gainIndex*2];

    return 0;
}


long getDacBinVoltCalibrated8Bit(u6CalibrationInfo *caliInfo, int dacNumber, double analogVolt, uint8 *bytesVolt8)
{
    uint16 u16BytesVolt = 0;

    if( getDacBinVoltCalibrated16Bit(caliInfo, dacNumber, analogVolt, &u16BytesVolt) != -1 )
    {
        *bytesVolt8 = (uint8)(u16BytesVolt/256);
        return 0;
    }
    return -1;
}


long getDacBinVoltCalibrated16Bit(u6CalibrationInfo *caliInfo, int dacNumber, double analogVolt, uint16 *bytesVolt16)
{
    uint32 dBytesVolt;

    if( isCalibrationInfoValid(caliInfo) == 0 )
        return -1;

    if( dacNumber < 0 || dacNumber > 2 )
    {
        printf("getDacBinVoltCalibrated error: invalid channelNumber.\n");
        return -1;
    }

    dBytesVolt = analogVolt*caliInfo->ccConstants[16 + dacNumber*2] + caliInfo->ccConstants[17 + dacNumber*2];

    //Checking to make sure bytesVolt will be a value between 0 and 65535.
    if( dBytesVolt > 65535 )
        dBytesVolt = 65535;

    *bytesVolt16 = (uint16)dBytesVolt;

    return 0;
}


long getTempKCalibrated(u6CalibrationInfo *caliInfo, int resolutionIndex, int gainIndex, int bits24, uint32 bytesTemp, double *kelvinTemp)
{
    double value;

    //convert to voltage first
    if( getAinVoltCalibrated(caliInfo, resolutionIndex, gainIndex, bits24, bytesTemp, &value) == -1 )
        return -1;

    *kelvinTemp = caliInfo->ccConstants[22]*value + caliInfo->ccConstants[23];
    return 0;
}

long getTdacBinVoltCalibrated(u6TdacCalibrationInfo *caliInfo, int dacNumber, double analogVolt, uint16 *bytesVolt)
{
    uint32 dBytesVolt;

    if( isTdacCalibrationInfoValid(caliInfo) == 0 )
        return -1;

    if( dacNumber < 0 || dacNumber > 2 )
    {
        printf("getTdacBinVoltCalibrated error: invalid channelNumber.\n");
        return -1;
    }

    dBytesVolt = analogVolt*caliInfo->ccConstants[dacNumber*2] + caliInfo->ccConstants[dacNumber*2 + 1];

    //Checking to make sure bytesVolt will be a value between 0 and 65535.
    if( dBytesVolt > 65535 )
        dBytesVolt = 65535;

    *bytesVolt = (uint16)dBytesVolt;

    return 0;
}


long getAinVoltUncalibrated(int resolutionIndex, int gainIndex, int bits24, uint32 bytesVolt, double *analogVolt)
{
    return getAinVoltCalibrated(&U6_CALIBRATION_INFO_DEFAULT, resolutionIndex, gainIndex, bits24, bytesVolt, analogVolt);
}


long getDacBinVoltUncalibrated8Bit(int dacNumber, double analogVolt, uint8 *bytesVolt8)
{
    return getDacBinVoltCalibrated8Bit(&U6_CALIBRATION_INFO_DEFAULT, dacNumber, analogVolt, bytesVolt8);
}


long getDacBinVoltUncalibrated16Bit(int dacNumber, double analogVolt, uint16 *bytesVolt16)
{
    return getDacBinVoltCalibrated16Bit(&U6_CALIBRATION_INFO_DEFAULT, dacNumber, analogVolt, bytesVolt16);
}


long getTempKUncalibrated(int resolutionIndex, int gainIndex, int bits24, uint32 bytesTemp, double *kelvinTemp)
{
    return getTempKCalibrated(&U6_CALIBRATION_INFO_DEFAULT, resolutionIndex, gainIndex, bits24, bytesTemp, kelvinTemp);
}

long I2C(HANDLE hDevice, uint8 I2COptions, uint8 SpeedAdjust, uint8 SDAPinNum, uint8 SCLPinNum, uint8 Address, uint8 NumI2CBytesToSend, uint8 NumI2CBytesToReceive, uint8 *I2CBytesCommand, uint8 *Errorcode, uint8 *AckArray, uint8 *I2CBytesResponse)
{
    uint8 *sendBuff, *recBuff;
    uint16 checksumTotal = 0;
    uint32 ackArrayTotal, expectedAckArray;
    int sendChars, recChars, sendSize, recSize, i, ret;

    *Errorcode = 0;
    ret = 0;
    sendSize = 6 + 8 + ((NumI2CBytesToSend%2 != 0)?(NumI2CBytesToSend + 1):(NumI2CBytesToSend));
    recSize = 6 + 6 + ((NumI2CBytesToReceive%2 != 0)?(NumI2CBytesToReceive + 1):(NumI2CBytesToReceive));

    sendBuff = (uint8 *)malloc(sizeof(uint8)*sendSize);
    recBuff = (uint8 *)malloc(sizeof(uint8)*recSize);

    sendBuff[sendSize - 1] = 0;

    //I2C command
    sendBuff[1] = (uint8)(0xF8);     //Command byte
    sendBuff[2] = (sendSize - 6)/2;  //Number of data words = 4 + NumI2CBytesToSend
    sendBuff[3] = (uint8)(0x3B);     //Extended command number

    sendBuff[6] = I2COptions;             //I2COptions
    sendBuff[7] = SpeedAdjust;            //SpeedAdjust
    sendBuff[8] = SDAPinNum;              //SDAPinNum
    sendBuff[9] = SCLPinNum;              //SCLPinNum
    sendBuff[10] = Address;               //Address
    sendBuff[11] = 0;                     //Reserved
    sendBuff[12] = NumI2CBytesToSend;     //NumI2CByteToSend
    sendBuff[13] = NumI2CBytesToReceive;  //NumI2CBytesToReceive

    for( i = 0; i < NumI2CBytesToSend; i++ )
        sendBuff[14 + i] = I2CBytesCommand[i];  //I2CByte

    extendedChecksum(sendBuff, sendSize);

    //Sending command to U6
    sendChars = LJUSB_Write(hDevice, sendBuff, sendSize);
    if( sendChars < sendSize )
    {
        if( sendChars == 0 )
            printf("I2C Error : write failed\n");
        else
            printf("I2C Error : did not write all of the buffer\n");
        ret = -1;
        goto cleanmem;
    }

    //Reading response from U6
    recChars = LJUSB_Read(hDevice, recBuff, recSize);
    if( recChars < recSize )
    {
        if( recChars == 0 )
            printf("I2C Error : read failed\n");
        else
        {
            printf("I2C Error : did not read all of the buffer\n");
            if( recChars >= 12 )
                *Errorcode = recBuff[6];
        }
        ret = -1;
        goto cleanmem;
    }

    *Errorcode = recBuff[6];

    AckArray[0] = recBuff[8];
    AckArray[1] = recBuff[9];
    AckArray[2] = recBuff[10];
    AckArray[3] = recBuff[11];

    for( i = 0; i < NumI2CBytesToReceive; i++ )
        I2CBytesResponse[i] = recBuff[12 + i];

    if( (uint8)(extendedChecksum8(recBuff)) != recBuff[0] )
    {
        printf("I2C Error : read buffer has bad checksum (%d)\n", recBuff[0]);
        ret = -1;
    }

    if( recBuff[1] != (uint8)(0xF8) )
    {
        printf("I2C Error : read buffer has incorrect command byte (%d)\n", recBuff[1]);
        ret = -1;
    }

    if( recBuff[2] != (uint8)((recSize - 6)/2) )
    {
        printf("I2C Error : read buffer has incorrect number of data words (%d)\n", recBuff[2]);
        ret = -1;
    }

    if( recBuff[3] != (uint8)(0x3B) )
    {
        printf("I2C Error : read buffer has incorrect extended command number (%d)\n", recBuff[3]);
        ret = -1;
    }

    checksumTotal = extendedChecksum16(recBuff, recSize);
    if( (uint8)((checksumTotal / 256) & 0xff) != recBuff[5] || (uint8)(checksumTotal & 255) != recBuff[4] )
    {
        printf("I2C error : read buffer has bad checksum16 (%u)\n", checksumTotal);
        ret = -1;
    }

    //ackArray should ack the Address byte in the first ack bit
    ackArrayTotal = AckArray[0] + AckArray[1]*256 + AckArray[2]*65536 + AckArray[3]*16777216;
    expectedAckArray = pow(2.0,  NumI2CBytesToSend+1)-1;
    if( ackArrayTotal != expectedAckArray )
        printf("I2C error : expected an ack of %u, but received %u\n", expectedAckArray, ackArrayTotal);

cleanmem:
    free(sendBuff);
    free(recBuff);
    sendBuff = NULL;
    recBuff = NULL;

    return ret;
}


long eAIN(HANDLE Handle, u6CalibrationInfo *CalibrationInfo, long ChannelP, long ChannelN, double *Voltage, long Range, long Resolution, long Settling, long Binary, long Reserved1, long Reserved2)
{
    uint8 diff, gain, Errorcode, ErrorFrame;
    uint8 sendDataBuff[4], recDataBuff[5];
    uint32 bytesV;

    if( isCalibrationInfoValid(CalibrationInfo) == 0 )
    {
        printf("eAIN error: Invalid calibration information.\n");
        return -1;
    }

    //Checking if acceptable positive channel
    if( ChannelP < 0 || ChannelP > 143 )
    {
        printf("eAIN error: Invalid ChannelP value.\n");
        return -1;
    }

    //Checking if single ended or differential readin
    if( ChannelN == 0 || ChannelN == 15 )
    {
        //Single ended reading
        diff = 0;
    }
    else if( (ChannelN&1) == 1 && ChannelN == ChannelP + 1 )
    {
        //Differential reading
        diff = 1;
    }
    else
    {
        printf("eAIN error: Invalid ChannelN value.\n");
        return -1;
    }

    if( Range == LJ_rgAUTO )
        gain = 15;
    else if( Range == LJ_rgBIP10V )
        gain = 0;
    else if( Range == LJ_rgBIP1V )
        gain = 1;
    else if( Range == LJ_rgBIPP1V )
        gain = 2;
    else if( Range == LJ_rgBIPP01V )
        gain = 3;
    else
    {
        printf("eAIN error: Invalid Range value\n");
        return -1;
    }

    if( Resolution < 0 || Resolution > 13 )
    {
        printf("eAIN error: Invalid Resolution value\n");
        return -1;
    }

    if( Settling < 0 && Settling > 4 )
    {
        printf("eAIN error: Invalid Settling value\n");
        return -1;
    }

    /* Setting up Feedback command to read analog input */
    sendDataBuff[0] = 3;    //IOType is AIN24AR

    sendDataBuff[1] = (uint8)ChannelP; //Positive channel
    sendDataBuff[2] = (uint8)Resolution + gain*16; //Res Index (0-3), Gain Index (4-7)
    sendDataBuff[3] = (uint8)Settling + diff*128; //Settling factor (0-2), Differential (7)

    if( ehFeedback(Handle, sendDataBuff, 4, &Errorcode, &ErrorFrame, recDataBuff, 5) < 0 )
        return -1;
    if( Errorcode )
        return (long)Errorcode;

    bytesV = recDataBuff[0] + ((uint32)recDataBuff[1])*256 + ((uint32)recDataBuff[2])*65536;
    gain = recDataBuff[3]/16;

    if( Binary != 0 )
    {
        *Voltage = (double)bytesV;
    }
    else
    {
        if( ChannelP == 14 )
        {
            if( getTempKCalibrated(CalibrationInfo, Resolution, gain, 1, bytesV, Voltage) < 0 )
                return -1;
        }
        else
        {
            gain = recDataBuff[3]/16;
            if( getAinVoltCalibrated(CalibrationInfo, Resolution, gain, 1, bytesV, Voltage) < 0 )
                return -1;
        }
    }

    return 0;
}


long eDAC(HANDLE Handle, u6CalibrationInfo *CalibrationInfo, long Channel, double Voltage, long Binary, long Reserved1, long Reserved2)
{
    uint8 Errorcode, ErrorFrame;
    uint8 sendDataBuff[3];
    uint16 bytesV;
    long sendSize;

    if( isCalibrationInfoValid(CalibrationInfo) == 0 )
    {
        printf("eDAC error: Invalid calibration information.\n");
        return -1;
    }

    if( Channel < 0 || Channel > 1 )
    {
        printf("eDAC error: Invalid Channel.\n");
        return -1;
    }

    sendSize = 3;

    sendDataBuff[0] = 38 + Channel;  //IOType is DAC0/1 (16 bit)

    if( getDacBinVoltCalibrated16Bit(CalibrationInfo, (int)Channel, Voltage, &bytesV) < 0 )
        return -1;

    sendDataBuff[1] = (uint8)(bytesV&255);          //Value LSB
    sendDataBuff[2] = (uint8)((bytesV&65280)/256);  //Value MSB

    if( ehFeedback(Handle, sendDataBuff, sendSize, &Errorcode, &ErrorFrame, NULL, 0) < 0 )
        return -1;
    if( Errorcode )
        return (long)Errorcode;

    return 0;
}


long eDI(HANDLE Handle, long Channel, long *State)
{
    uint8 sendDataBuff[4], recDataBuff[1];
    uint8 Errorcode, ErrorFrame;

    if( Channel < 0 || Channel > 19 )
    {
        printf("eDI error: Invalid Channel.\n");
        return -1;
    }


    /* Setting up Feedback command to set digital Channel to input and to read from it */
    sendDataBuff[0] = 13;       //IOType is BitDirWrite
    sendDataBuff[1] = Channel;  //IONumber(bits 0-4) + Direction (bit 7)

    sendDataBuff[2] = 10;       //IOType is BitStateRead
    sendDataBuff[3] = Channel;  //IONumber

    if( ehFeedback(Handle, sendDataBuff, 4, &Errorcode, &ErrorFrame, recDataBuff, 1) < 0 )
        return -1;
    if( Errorcode )
        return (long)Errorcode;

    *State = recDataBuff[0];
    return 0;
}


long eDO(HANDLE Handle, long Channel, long State)
{
    uint8 Errorcode, ErrorFrame;
    uint8 sendDataBuff[4];

    if( Channel < 0 || Channel > 19 )
    {
        printf("eD0 error: Invalid Channel\n");
        return -1;
    }

    /* Setting up Feedback command to set digital Channel to output and to set the state */
    sendDataBuff[0] = 13;             //IOType is BitDirWrite
    sendDataBuff[1] = Channel + 128;  //IONumber(bits 0-4) + Direction (bit 7)

    sendDataBuff[2] = 11;             //IOType is BitStateWrite
    sendDataBuff[3] = Channel + 128*((State > 0) ? 1 : 0);  //IONumber(bits 0-4) + State (bit 7)

    if( ehFeedback(Handle, sendDataBuff, 4, &Errorcode, &ErrorFrame, NULL, 0) < 0 )
        return -1;
    if( Errorcode )
        return (long)Errorcode;

    return 0;
}


long eTCConfig(HANDLE Handle, long *aEnableTimers, long *aEnableCounters, long TCPinOffset, long TimerClockBaseIndex, long TimerClockDivisor, long *aTimerModes, double *aTimerValues, long Reserved1, long Reserved2)
{
    uint8 sendDataBuff[20];
    uint8 numTimers, counters, cNumTimers, cCounters, cPinOffset, Errorcode, ErrorFrame;
    int sendDataBuffSize, i;
    long error;
 
    if( TCPinOffset < 0 && TCPinOffset > 8)
    {
        printf("eTCConfig error: Invalid TCPinOffset.\n");
        return -1;
    }

    /* ConfigTimerClock */
    if( TimerClockBaseIndex == LJ_tc4MHZ || TimerClockBaseIndex ==  LJ_tc12MHZ || TimerClockBaseIndex == LJ_tc48MHZ ||
        TimerClockBaseIndex == LJ_tc1MHZ_DIV || TimerClockBaseIndex == LJ_tc4MHZ_DIV || TimerClockBaseIndex == LJ_tc12MHZ_DIV ||
        TimerClockBaseIndex == LJ_tc48MHZ_DIV )
        TimerClockBaseIndex = TimerClockBaseIndex - 20;

    error = ehConfigTimerClock(Handle, (uint8)(TimerClockBaseIndex + 128), (uint8)TimerClockDivisor, NULL, NULL);
    if( error != 0 )
        return error;

    numTimers = 0;
    counters = 0;

    for( i = 0; i < 4; i++ )
    {
        if( aEnableTimers[i] != 0 )
            numTimers++;
        else
            i = 999;
    }

    for( i = 0; i < 2; i++ )
    {
        if( aEnableCounters[i] != 0 )
        {
            counters += pow(2, i);
        }
    }

    error = ehConfigIO(Handle, 1, numTimers, counters, TCPinOffset, &cNumTimers, &cCounters, &cPinOffset);
    if( error != 0 )
        return error;

    if( numTimers > 0 )
    {
        /* Feedback */
        for( i = 0; i < 8; i++ )
            sendDataBuff[i] = 0;

        for( i = 0; i < numTimers; i++ )
        {
            sendDataBuff[i*4] = 43 + i*2;                                         //TimerConfig
            sendDataBuff[1 + i*4] = (uint8)aTimerModes[i];                        //TimerMode
            sendDataBuff[2 + i*4] = (uint8)(((long)aTimerValues[i])&0x00ff);        //Value LSB
            sendDataBuff[3 + i*4] = (uint8)((((long)aTimerValues[i])&0xff00)/256);  //Value MSB
        }

        sendDataBuffSize = 4*numTimers;

        if( ehFeedback(Handle, sendDataBuff, sendDataBuffSize, &Errorcode, &ErrorFrame, NULL, 0) < 0 )
            return -1;
        if( Errorcode )
            return (long)Errorcode;
    }

    return 0;
}


long eTCValues(HANDLE Handle, long *aReadTimers, long *aUpdateResetTimers, long *aReadCounters, long *aResetCounters, double *aTimerValues, double *aCounterValues, long Reserved1, long Reserved2)
{
    uint8 Errorcode, ErrorFrame;
    uint8 sendDataBuff[20], recDataBuff[24];
    int sendDataBuffSize, recDataBuffSize, i, j;
    int numTimers, dataCountCounter, dataCountTimer;

    /* Feedback */
    numTimers = 0;
    dataCountCounter = 0;
    dataCountTimer = 0;
    sendDataBuffSize = 0;
    recDataBuffSize = 0;

    for( i = 0; i < 4; i++ )
    {
        if( aReadTimers[i] != 0 || aUpdateResetTimers[i] != 0 )
        {
            sendDataBuff[sendDataBuffSize] = 42 + i*2;                                          //Timer
            sendDataBuff[1 + sendDataBuffSize] = ((aUpdateResetTimers[i] != 0) ? 1 : 0);        //UpdateReset
            sendDataBuff[2 + sendDataBuffSize] = (uint8)(((long)aTimerValues[i])&0x00ff);       //Value LSB
            sendDataBuff[3 + sendDataBuffSize] = (uint8)((((long)aTimerValues[i])&0xff00)/256); //Value MSB
            sendDataBuffSize += 4;
            recDataBuffSize += 4;
            numTimers++;
        }
    }

    for( i = 0; i < 2; i++ )
    {
        if( aReadCounters[i] != 0 || aResetCounters[i] != 0 )
        {
            sendDataBuff[sendDataBuffSize] = 54 + i;                                 //Counter
            sendDataBuff[1 + sendDataBuffSize] = ((aResetCounters[i] != 0) ? 1 : 0); //Reset
            sendDataBuffSize += 2;
            recDataBuffSize += 4;
        }
    }

    if( ehFeedback(Handle, sendDataBuff, sendDataBuffSize, &Errorcode, &ErrorFrame, recDataBuff, recDataBuffSize) < 0 )
        return -1;
    if( Errorcode )
        return (long)Errorcode;

    for( i = 0; i < 4; i++ )
    {
        aTimerValues[i] = 0;
        if( aReadTimers[i] != 0 )
        {
            for( j = 0; j < 4; j++ )
                aTimerValues[i] += (double)((long)recDataBuff[j + dataCountTimer*4]*pow(2, 8*j));
        }
        if( aReadTimers[i] != 0 || aUpdateResetTimers[i] != 0 )
            dataCountTimer++;

        if( i < 2 )
        {
            aCounterValues[i] = 0;
            if( aReadCounters[i] != 0 )
            {
                for( j = 0; j < 4; j++ )
                    aCounterValues[i] += (double)((long)recDataBuff[j + numTimers*4 + dataCountCounter*4]*pow(2, 8*j));
            }
            if( aReadCounters[i] != 0 || aResetCounters[i] != 0 )
                dataCountCounter++;
        }
    }

    return 0;
}


long ehConfigIO(HANDLE hDevice, uint8 inWriteMask, uint8 inNumberTimersEnabled, uint8 inCounterEnable, uint8 inPinOffset, uint8 *outNumberTimersEnabled, uint8 *outCounterEnable, uint8 *outPinOffset)
{
    uint8 sendBuff[16], recBuff[16];
    uint16 checksumTotal;
    int sendChars, recChars, i;

    sendBuff[1] = (uint8)(0xF8);  //Command byte
    sendBuff[2] = (uint8)(0x05);  //Number of data words
    sendBuff[3] = (uint8)(0x0B);  //Extended command number

    sendBuff[6] = inWriteMask;  //Writemask

    sendBuff[7] = inNumberTimersEnabled;
    sendBuff[8] = inCounterEnable;
    sendBuff[9] = inPinOffset;

    for( i = 10; i < 16; i++ )
        sendBuff[i] = 0;

    extendedChecksum(sendBuff, 16);

    //Sending command to U6
    if( (sendChars = LJUSB_Write(hDevice, sendBuff, 16)) < 16 )
    {
        if( sendChars == 0 )
            printf("ehConfigIO error : write failed\n");
        else
            printf("ehConfigIO error : did not write all of the buffer\n");
        return -1;
    }

    //Reading response from U6
    if( (recChars = LJUSB_Read(hDevice, recBuff, 16)) < 16 )
    {
        if( recChars == 0 )
            printf("ehConfigIO error : read failed\n");
        else
            printf("ehConfigIO error : did not read all of the buffer\n");
        return -1;
    }

    checksumTotal = extendedChecksum16(recBuff, 16);
    if( (uint8)((checksumTotal / 256 ) & 0xff) != recBuff[5] )
    {
        printf("ehConfigIO error : read buffer has bad checksum16(MSB)\n");
        return -1;
    }

    if( (uint8)(checksumTotal & 0xff) != recBuff[4] )
    {
        printf("ehConfigIO error : read buffer has bad checksum16(LBS)\n");
        return -1;
    }

    if( extendedChecksum8(recBuff) != recBuff[0] )
    {
        printf("ehConfigIO error : read buffer has bad checksum8\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x05) || recBuff[3] != (uint8)(0x0B) )
    {
        printf("ehConfigIO error : read buffer has wrong command bytes\n");
        return -1;
    }

    if( recBuff[6] != 0 )
    {
        printf("ehConfigIO error : read buffer received errorcode %d\n", recBuff[6]);
        return (int)recBuff[6];
    }

    if( outNumberTimersEnabled != NULL )
        *outNumberTimersEnabled = recBuff[7];
    if( outCounterEnable != NULL )
        *outCounterEnable = recBuff[8];
    if( outPinOffset != NULL)
        *outPinOffset = recBuff[9];

    return 0;
}


long ehConfigTimerClock(HANDLE hDevice, uint8 inTimerClockConfig, uint8 inTimerClockDivisor, uint8 *outTimerClockConfig, uint8 *outTimerClockDivisor)
{
    uint8 sendBuff[10], recBuff[10];
    uint16 checksumTotal;
    int sendChars, recChars;

    sendBuff[1] = (uint8)(0xF8);  //Command byte
    sendBuff[2] = (uint8)(0x02);  //Number of data words
    sendBuff[3] = (uint8)(0x0A);  //Extended command number

    sendBuff[6] = 0;   //Reserved
    sendBuff[7] = 0;   //Reserved

    sendBuff[8] = inTimerClockConfig;   //TimerClockConfig
    sendBuff[9] = inTimerClockDivisor;  //TimerClockDivisor
    extendedChecksum(sendBuff, 10);

    //Sending command to U6
    if( (sendChars = LJUSB_Write(hDevice, sendBuff, 10)) < 10 )
    {
        if( sendChars == 0 )
            printf("ehConfigTimerClock error : write failed\n");
        else
            printf("ehConfigTimerClock error : did not write all of the buffer\n");
        return -1;
    }

    //Reading response from U6
    if( (recChars = LJUSB_Read(hDevice, recBuff, 10)) < 10 )
    {
        if( recChars == 0 )
            printf("ehConfigTimerClock error : read failed\n");
        else
            printf("ehConfigTimerClock error : did not read all of the buffer\n");
        return -1;
    }

    checksumTotal = extendedChecksum16(recBuff, 10);
    if( (uint8)((checksumTotal / 256 ) & 0xff) != recBuff[5] )
    {
        printf("ehConfigTimerClock error : read buffer has bad checksum16(MSB)\n");
        return -1;
    }

    if( (uint8)(checksumTotal & 0xff) != recBuff[4] )
    {
        printf("ehConfigTimerClock error : read buffer has bad checksum16(LBS)\n");
        return -1;
    }

    if( extendedChecksum8(recBuff) != recBuff[0] )
    {
        printf("ehConfigTimerClock error : read buffer has bad checksum8\n");
        return -1;
    }

    if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x02) || recBuff[3] != (uint8)(0x0A) )
    {
        printf("ehConfigTimerClock error : read buffer has wrong command bytes\n");
        return -1;
    }

    if( outTimerClockConfig != NULL )
        *outTimerClockConfig = recBuff[8];

    if( outTimerClockDivisor != NULL )
        *outTimerClockDivisor = recBuff[9];

    if( recBuff[6] != 0 )
    {
        printf("ehConfigTimerClock error : read buffer received errorcode %d\n", recBuff[6]);
        return recBuff[6];
    }

    return 0;
}


long ehFeedback(HANDLE hDevice, uint8 *inIOTypesDataBuff, long inIOTypesDataSize, uint8 *outErrorcode, uint8 *outErrorFrame, uint8 *outDataBuff, long outDataSize)
{
    uint8 *sendBuff, *recBuff;
    uint16 checksumTotal;
    int sendChars, recChars, i, sendDWSize, recDWSize, commandBytes, ret;

    ret = 0;
    commandBytes = 6;

    if( ((sendDWSize = inIOTypesDataSize + 1)%2) != 0 )
        sendDWSize++;
    if( ((recDWSize = outDataSize + 3)%2) != 0 )
        recDWSize++;

    sendBuff = (uint8 *)malloc(sizeof(uint8)*(commandBytes + sendDWSize));
    recBuff = (uint8 *)malloc(sizeof(uint8)*(commandBytes + recDWSize));

    if( sendBuff == NULL || recBuff == NULL )
    {
        ret = -1;
        goto cleanmem;
    }

    sendBuff[sendDWSize + commandBytes - 1] = 0;

    /* Setting up Feedback command */
    sendBuff[1] = (uint8)(0xF8);  //Command byte
    sendBuff[2] = sendDWSize/2;   //Number of data words (.5 word for echo, 1.5
                                  //words for IOTypes)
    sendBuff[3] = (uint8)(0x00);  //Extended command number

    sendBuff[6] = 0;    //Echo

    for( i = 0; i < inIOTypesDataSize; i++ )
        sendBuff[i+commandBytes+1] = inIOTypesDataBuff[i];

    extendedChecksum(sendBuff, (sendDWSize+commandBytes));

    //Sending command to U6
    if( (sendChars = LJUSB_Write(hDevice, sendBuff, (sendDWSize+commandBytes))) < sendDWSize+commandBytes )
    {
        if( sendChars == 0 )
            printf("ehFeedback error : write failed\n");
        else
            printf("ehFeedback error : did not write all of the buffer\n");
        ret = -1;
        goto cleanmem;
    }

    //Reading response from U6
    if( (recChars = LJUSB_Read(hDevice, recBuff, (commandBytes+recDWSize))) < commandBytes+recDWSize )
    {
        if( recChars == -1 )
        {
            printf("ehFeedback error : read failed\n");
            ret = -1;
            goto cleanmem;
        }
        else if( recChars < 8 )
        {
            printf("ehFeedback error : response buffer is too small\n");
            for( i = 0; i < recChars; i++ )
                printf("%d ", recBuff[i]);
            ret = -1;
            goto cleanmem;
        }
        else
            printf("ehFeedback error : did not read all of the expected buffer (received %d, expected %d )\n", recChars, commandBytes+recDWSize);
    }

    checksumTotal = extendedChecksum16(recBuff, recChars);
    if( (uint8)((checksumTotal / 256 ) & 0xff) != recBuff[5] )
    {
        printf("ehFeedback error : read buffer has bad checksum16(MSB)\n");
        ret = -1;
        goto cleanmem;
    }

    if( (uint8)(checksumTotal & 0xff) != recBuff[4] )
    {
        printf("ehFeedback error : read buffer has bad checksum16(LBS)\n");
        ret = -1;
        goto cleanmem;
    }

    if( extendedChecksum8(recBuff) != recBuff[0] )
    {
        printf("ehFeedback error : read buffer has bad checksum8\n");
        ret = -1;
        goto cleanmem;
    }

    if( recBuff[1] != (uint8)(0xF8) || recBuff[3] != (uint8)(0x00) )
    {
        printf("ehFeedback error : read buffer has wrong command bytes \n");
        ret = -1;
        goto cleanmem;
    }

    *outErrorcode = recBuff[6];
    *outErrorFrame = recBuff[7];

    for( i = 0; i+commandBytes+3 < recChars && i < outDataSize; i++ )
        outDataBuff[i] = recBuff[i+commandBytes+3];

cleanmem:
    free(sendBuff);
    free(recBuff);
    sendBuff = NULL;
    recBuff = NULL;

    return ret;
}
