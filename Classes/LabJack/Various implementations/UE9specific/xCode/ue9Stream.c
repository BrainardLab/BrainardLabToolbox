//Author: LabJack
//Oct. 3, 2007
//This example program reads analog inputs AI0 - AI3 (default) using stream mode

#include "ue9.h"

char *ipAddress;
const int ue9_portA = 52360;
const int ue9_portB = 52361;
const int ainResolution = 12;
const uint8 NumChannels = 4;        //For this example to work proper, NumChannels needs
                                    //to be 1, 2, 4, 8 or 16

int StreamConfig_example(int socketFD);
int StreamStart(int socketFD);
int StreamData_example(int socketFDA, int socketFDB, ue9CalibrationInfo *caliInfo);
int StreamStop(int socketFDA, int displayError);
int flushStream(int socketFD);
int doFlush(int socketFDA);

int main(int argc, char **argv)
{
  int socketFDA, socketFDB;
  ue9CalibrationInfo caliInfo;
  socketFDA = -1;
  socketFDB = -1;

  if(argc < 2)
  {
    printf("Please enter an ip address to connect to.\n");
    exit(0);
  }
  else if(argc > 2)
  {
    printf("Too many arguments.\nPlease enter only an ip address.\n");
    exit(0);
  }

  ipAddress = argv[1];

  if( (socketFDA = openTCPConnection(ipAddress, ue9_portA)) < 0)
    goto exit;

  doFlush(socketFDA);

  if( (socketFDB = openTCPConnection(ipAddress, ue9_portB)) < 0)
    goto close;

  if(getCalibrationInfo(socketFDA, &caliInfo) < 0)
    goto close;

  if(StreamConfig_example(socketFDA) != 0)
    goto close;

  if(StreamStart(socketFDA) != 0)
    goto close;

  StreamData_example(socketFDA, socketFDB, &caliInfo);
  StreamStop(socketFDA, 1);

close:
  if(closeTCPConnection(socketFDA) < 0)
    printf("Error: failed to close socket (portA)\n");
  if(closeTCPConnection(socketFDB) < 0)
    printf("Error: failed to close socket (portB)\n");
exit:
  return 0;
}

//Sends a StreamConfig low-level command to configure the stream to read 
//NumChannels analog inputs.
int StreamConfig_example(int socketFD)
{
  int sendBuffSize;
  uint8 *sendBuff;
  uint8 recBuff[8];
  int sendChars, recChars, i, ret;
  uint16 checksumTotal, scanInterval;

  sendBuffSize = 12 + 2*NumChannels;
  sendBuff = malloc(sizeof(uint8)*sendBuffSize);
  ret = 0;  
  
  sendBuff[1] = (uint8)(0xF8);      //command byte
  sendBuff[2] = NumChannels + 3;    //number of data words : NumChannels + 3
  sendBuff[3] = (uint8)(0x11);      //extended command number
  sendBuff[6] = (uint8)NumChannels; //NumChannels
  sendBuff[7] = ainResolution;      //resolution
  sendBuff[8] = 0;                  //SettlingTime = 0
  sendBuff[9] = 0;                  //ScanConfig: scan pulse and external scan 
                                    //trigger disabled, stream clock 
                                    //frequency = 4 MHz

  scanInterval = 4000;
  sendBuff[10] = (uint8)(scanInterval & 0x00FF); //scan interval (low byte)
  sendBuff[11] = (uint8)(scanInterval / 256);	   //scan interval (high byte)
  
  for(i = 0; i < NumChannels; i++)
  {
    sendBuff[12 + i*2] = i; //channel # = i
    sendBuff[13 + i*2] = 0; //BipGain (Bip = unipolar, Gain = 1)
  }

  extendedChecksum(sendBuff, sendBuffSize);

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, sendBuffSize, 0);
  if(sendChars < 20)
  {
    if(sendChars == -1)
      printf("Error : send failed (StreamConfig)\n");
    else
      printf("Error : did not send all of the buffer (StreamConfig)\n");
    ret = -1;
    goto cleanmem;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 8, 0);
  if(recChars < 8)
  {
    if(recChars == -1)
      printf("Error : receive failed (StreamConfig)\n");
    else
      printf("Error : did not receive all of the buffer (StreamConfig)\n");
    goto cleanmem;
  }

  checksumTotal = extendedChecksum16(recBuff, 8);
  if( (uint8)((checksumTotal / 256) & 0xff) != recBuff[5])
  {
    printf("Error : received buffer has bad checksum16(MSB) (StreamConfig)\n");
    ret = -1;
    goto cleanmem;
  }

  if( (uint8)(checksumTotal & 0xff) != recBuff[4])
  {
    printf("Error : received buffer has bad checksum16(LBS) (StreamConfig)\n");
    ret = -1;
    goto cleanmem;
  }

  if( extendedChecksum8(recBuff) != recBuff[0])
  {
    printf("Error : received buffer has bad checksum8 (StreamConfig)\n");
    ret = -1;
    goto cleanmem;
  }

  if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x01) || recBuff[3] != (uint8)(0x11) || recBuff[7] != (uint8)(0x00))
  {
    printf("Error : received buffer has wrong command bytes (StreamConfig)\n");
    ret = -1;
    goto cleanmem;
  }

  if(recBuff[6] != 0)
  {
    printf("Errorcode # %d from StreamConfig received.\n", (unsigned int)recBuff[6]);
    ret = -1;
    goto cleanmem;   
  }

cleanmem:
  free(sendBuff);
  sendBuff = NULL;

  return ret;
}

//Sends a StreamStart low-level command to start streaming.
int StreamStart(int socketFD)
{
  uint8 sendBuff[2], recBuff[4];
  int sendChars, recChars;

  sendBuff[0] = (uint8)(0xA8);  //CheckSum8
  sendBuff[1] = (uint8)(0xA8);  //command byte

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, 2, 0);
  if(sendChars < 2)
  {
    if(sendChars == -1)
      printf("Error : send failed\n");
    else  
      printf("Error : did not send all of the buffer\n");
    return -1;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 4, 0);
  if(recChars < 4)
  {
    if(recChars == -1)
      printf("Error : receive failed\n");
    else  
      printf("Error : did not receive all of the buffer\n");
    return -1;
  }

  if( recBuff[1] != (uint8)(0xA9) || recBuff[3] != (uint8)(0x00) )
  {
    printf("Error : received buffer has wrong command bytes \n");
    return -1;
  }

  if(recBuff[2] != 0)
  {
    printf("Errorcode # %d from StreamStart received.\n", (unsigned int)recBuff[2]);
    return -1;
  }

  return 0;
}

//Reads the StreamData low-level function response in a loop.  All voltages from
//the stream are stored in the voltages 2D array.
int StreamData_example(int socketFDA, int socketFDB, ue9CalibrationInfo *caliInfo)
{
  uint8 *recBuff;
  double **voltages;
  int recChars, backLog, overflow, totalScans, ret;
  int i, k, m, packetCounter, currChannel, scanNumber;
  int totalPackets;        //The total number of StreamData responses read
  uint16 voltageBytes, checksumTotal;

  
  int numDisplay;          //Number of times to display streaming information
  int readSizeMultiplier;  //Multiplier for the StreamData receive buffer size
  long startTime, endTime;

  packetCounter = 0;
  currChannel = 0;
  scanNumber = 0;
  totalPackets = 0;
  recChars = 0;
  numDisplay = 6;
  readSizeMultiplier = 120;
  ret = 0;
  
  /* Each StreamData response contains (16/NumChannels) * readSizeMultiplier
   * samples for each channel.
   * Total number of scans = (16 / NumChannels) * readSizeMultiplier * numDisplay
   */
  totalScans = (16/NumChannels)*readSizeMultiplier*numDisplay;
  voltages = malloc(sizeof(double)*totalScans);
  for(i = 0; i < totalScans; i++)
    voltages[i] = malloc(sizeof(double)*NumChannels);

  recBuff = malloc(sizeof(uint8)*46*readSizeMultiplier);

  printf("Reading Samples...\n");

  startTime = getTickCount();

  for (i = 0; i < numDisplay; i++)
  {
    /* You can read the multiple StreamData responses of 46 bytes to help
     * improve throughput.  In this example this multiple is adjusted by the 
     * readSizeMultiplier variable.  We may not read 46 * readSizeMultiplier 
     * bytes per each recv call, but we will continue reading until we read
     * 46 * readSizeMultiplier bytes total.
     */
    recChars = 0;
    for(k = 0; k < 46*readSizeMultiplier; k += recChars)
    {
      //Reading response from UE9
      recChars = recv(socketFDB, recBuff + k, 46*readSizeMultiplier - k, 0);
      if(recChars == 0)
      {
        printf("Error : read failed (StreamData).\n");
        ret = -1;
        goto cleanmem;
      }
    }
      
    overflow = 0;

    //Checking for errors and getting data out of each StreamData response
    for (m = 0; m < readSizeMultiplier; m++)
    {
      totalPackets++;

      checksumTotal = extendedChecksum16(recBuff + m*46, 46);
      if( (uint8)((checksumTotal / 256) & 0xff) != recBuff[m*46 + 5])
      {
        printf("Error : read buffer has bad checksum16(MSB) (StreamData).\n");
        ret = -1;
        goto cleanmem;
      }

      if( (uint8)(checksumTotal & 0xff) != recBuff[m*46 + 4])
      {
        printf("Error : read buffer has bad checksum16(LBS) (StreamData).\n");
        ret = -1;
        goto cleanmem;
      }

      checksumTotal = extendedChecksum8(recBuff + m*46);
      if( checksumTotal != recBuff[m*46])
      {
        printf("Error : read buffer has bad checksum8 (StreamData).\n");
        ret = -1;
        goto cleanmem;
      }

      if( recBuff[m*46 + 1] != (uint8)(0xF9) || recBuff[m*46 + 2] != (uint8)(0x14) || recBuff[m*46 + 3] != (uint8)(0xC0) )
      {
        printf("Error : read buffer has wrong command bytes (StreamData).\n");
        ret = -1;
        goto cleanmem;
      }

      if(recBuff[m*46 + 11] != 0)
      {
        printf("Errorcode # %d from StreamData read.\n", (unsigned int)recBuff[11]);
        ret = -1;
        goto cleanmem;
      }

      if(packetCounter != (int)recBuff[m*46 + 10])
      {
        printf("PacketCounter (%d) does not match with with current packet count (%d) (StreamData).\n", packetCounter, (int)recBuff[m*46 + 10]);
        ret = -1;
        goto cleanmem;
      }

      backLog = recBuff[m*46 + 45] & 0x7F;

      //Checking MSB for Comm buffer overflow
      if( (recBuff[m*46 + 45] & 128) == 128)
      {
        printf("\nComm buffer overflow detected in packet %d\n", totalPackets);
        printf("Current Comm backlog: %d\n", recBuff[m*46 + 45] & 0x7F);
        overflow = 1;
      }

      for(k = 12; k < 43; k += 2)
      {
        voltageBytes = (uint16)recBuff[m*46 + k] + (uint16)recBuff[m*46 + k+1] * 256;
        binaryToCalibratedAnalogVoltage(caliInfo, (uint8)(0x00), ainResolution, voltageBytes, &(voltages[scanNumber][currChannel])); 
        currChannel++;
        if(currChannel > 3)
        {
          currChannel = 0;
          scanNumber++;
        }
      }

      if(packetCounter >= 255)
        packetCounter = 0;
      else
        packetCounter++;

      //Handle Comm buffer overflow by stopping, flushing and restarting stream
      if(overflow == 1)
      {
        printf("\nRestarting stream...\n");

        doFlush(socketFDA);
        closeTCPConnection(socketFDB);

        if( (socketFDB = openTCPConnection(ipAddress, ue9_portB)) < 0)
          goto cleanmem;

        if(StreamConfig_example(socketFDA) != 0)
        {
          printf("Error restarting StreamConfig.\n");
          ret = -1;
          goto cleanmem;
        }

        if(StreamStart(socketFDA) != 0)
        {
          printf("Error restarting StreamStart.\n");
          ret = -1;
          goto cleanmem;
        }
        packetCounter = 0;
        break;
      }
    }

    printf("\nNumber of scans: %d\n", scanNumber);
    printf("Total packets read: %d\n", totalPackets);
    printf("Current PacketCounter: %d\n", ((packetCounter == 0) ? 255 : packetCounter-1));
    printf("Current Comm backlog: %d\n", backLog);

    for(k = 0; k < 4; k++)
      printf("  AI%d: %.4f V\n", k, voltages[scanNumber - 1][k]);
  }

  endTime = getTickCount();
  printf("\nRate of samples: %.0lf samples per second\n", (scanNumber*NumChannels)/((endTime - startTime)/1000.0));
  printf("Rate of scans: %.0lf scans per second\n\n", scanNumber/((endTime - startTime)/1000.0));

cleanmem:
  free(recBuff);
  recBuff = NULL;
  for(i = 0; i < totalScans; i++)
  {
    free(voltages[i]);
    voltages[i] = NULL;
  }
  free(voltages);
  voltages = NULL;

  return ret;
}

//Sends a StreamStop low-level command to stop streaming.
int StreamStop(int socketFD, int displayError)
{
  uint8 sendBuff[2], recBuff[4];
  int sendChars, recChars;

  sendBuff[0] = (uint8)(0xB0);  //CheckSum8
  sendBuff[1] = (uint8)(0xB0);  //command byte

  sendChars = send(socketFD, sendBuff, 2, 0);
  if(sendChars < 2)
  {
    if(displayError)
    {
      if(sendChars == -1)
        printf("Error : send failed (StreamStop)\n");
      else
        printf("Error : did not send all of the buffer (StreamStop)\n");
      return -1;
    }
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 4, 0);
  if(recChars < 4)
  {
    if(displayError)
    {
      if(recChars == -1)
        printf("Error : receive failed (StreamStop)\n");
      else
        printf("Error : did not receive all of the buffer (StreamStop)\n");
    }
    return -1;
  }

  if( recBuff[1] != (uint8)(0xB1) || recBuff[3] != (uint8)(0x00) )
  {
    if(displayError)
      printf("Error : received buffer has wrong command bytes (StreamStop)\n");
    return -1;
  }

  if(recBuff[2] != 0)
  {
    if(displayError)
      printf("Errorcode # %d from StreamStop received.\n", (unsigned int)recBuff[2]);
    return -1;
  }

  return 0;
}

//Sends a FlushBuffer low-level command to clear the stream buffer.
int flushStream(int socketFD)
{
  uint8 sendBuff[2], recBuff[2];
  int sendChars, recChars;

  sendBuff[0] = (uint8)(0x08);  //CheckSum8
  sendBuff[1] = (uint8)(0x08);  //command byte

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, 2, 0);
  if(sendChars < 2)
  {
    if(sendChars == -1)
      printf("Error : send failed (flushStream)\n");
    else  
      printf("Error : did not send all of the buffer (flushStream)\n");
    return -1;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 4, 0);
  if(recChars < 2)
  {
    if(recChars == -1)
      printf("Error : receive failed (flushStream)\n");
    else
      printf("Error : did not receive all of the buffer (flushStream)\n");
    return -1;
  }

  if(recBuff[0] != (uint8)(0x08) || recBuff[1] != (uint8)(0x08))
  {
    printf("Error : received buffer has wrong command bytes (flushStream)\n");
    return -1;
  }
  return 0;
}

//Runs StreamStop and flushStream low-level functions to flush out the streaming 
//buffer.  This function is useful for stopping streaming and clearing it after
//a Comm buffer overflow.
int doFlush(int socketFDA)
{
  printf("Flushing stream.\n");
  StreamStop(socketFDA, 0);
  flushStream(socketFDA);

  return 0;
}
