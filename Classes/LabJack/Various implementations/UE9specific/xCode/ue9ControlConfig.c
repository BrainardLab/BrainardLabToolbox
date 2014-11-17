//Author: LabJack
//Oct. 1, 2007
//This example program sends a ControlConfig low-level command, and reads the
//various parameters associated with the Control processor.
#include "ue9.h"

const int ue9_port = 52360;

int controlConfig_example(int socketFD, ue9CalibrationInfo *caliInfo);

int main(int argc, char **argv)
{
  int socketFD;
  ue9CalibrationInfo caliInfo;
  
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

  //Opening TCP connection to UE9
  if( (socketFD = openTCPConnection(argv[1], ue9_port)) < 0 )
    goto done;

  if(getCalibrationInfo(socketFD, &caliInfo) < 0)
    goto close;

  controlConfig_example(socketFD, &caliInfo);

close:
  if(closeTCPConnection(socketFD) < 0)
    printf("Error: failed to close socket\n");
done:
  return 0;
}

//Sends a ControlConfig low-level command to read the configuration settings
//associated with the Control chip.
int controlConfig_example(int socketFD, ue9CalibrationInfo *caliInfo)
{
  uint8 sendBuff[18], recBuff[24];
  int sendChars, recChars;
  int i;
  uint16 checksumTotal;
  double dac;

  sendBuff[1] = (uint8)(0xF8);  //command byte
  sendBuff[2] = (uint8)(0x06);  //number of data words
  sendBuff[3] = (uint8)(0x08);  //extended command number

  //WriteMask, PowerLevel, FIODir, etc. are all passed a value of
  //zero since we only want to read Control configuration settings,
  //not change them
  for(i = 6; i < 18; i++)
    sendBuff[i] = (uint8)(0x00);

  extendedChecksum(sendBuff,18);

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, 18, 0);
  if(sendChars < 18)
  {
    if(sendChars == -1)
      printf("Error : send failed\n");
    else  
      printf("Error : did not send all of the buffer\n");
    return -1;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 24, 0);
  if(recChars < 24)
  {
    if(recChars == -1)
      printf("Error : receive failed\n");
    else  
      printf("Error : did not receive all of the buffer\n");
    return -1;
  }

  checksumTotal = extendedChecksum16(recBuff, 24);
  if( (uint8)((checksumTotal / 256) & 0xff) != recBuff[5])
  {
    printf("Error : received buffer has bad checksum16(MSB)\n");
    return -1;
  }

  if( (uint8)(checksumTotal & 0xff) != recBuff[4])
  {
    printf("Error : received buffer has bad checksum16(LBS)\n");
    return -1;
  }

  if( extendedChecksum8(recBuff) != recBuff[0])
  {
    printf("Error : received buffer has bad checksum8\n");
    return -1;
  }

  if( recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x09) || recBuff[3] != (uint8)(0x08) )
  {
    printf("Error : received buffer has wrong command bytes \n");
    return -1;
  }

  if( recBuff[6] != 0)
  {
    printf("Errorcode (byte 6): %d\n", (uint32)recBuff[6]);
    return -1;
  }

  printf("PowerLevel default (byte 7): %d\n", (uint32)recBuff[7]);
  printf("ResetSource (byte 8): %d\n", (uint32)recBuff[8]);
  printf("ControlFW Version (bytes 9 and 10): %.3f\n", (uint32)recBuff[10] + (double)recBuff[9]/100.0);
  printf("ControlBL Version (bytes 11 and 12): %.3f\n", (uint32)recBuff[12] + (double)recBuff[11]/100.0);
  printf("HiRes Flag (byte 13): %d\n", (uint32)(recBuff[13]) & (0x01));
  printf("FIO default directions and states (bytes 14 and 15):\n");
  for(i = 0; i < 8; i++)
    printf("  FIO%d: %d and %d\n", i, ((recBuff[14]/(uint32)pow(2, i)) & 0x01), ((recBuff[15]/(uint32)pow(2, i)) & 0x01) );

  printf("EIO default directions and states (bytes 16 and 17):\n");
  for(i = 0; i < 8; i++)
    printf("  EIO%d: %d and %d\n", i, ((recBuff[16]/(uint32)pow(2, i)) & 0x01), ((recBuff[17]/(uint32)pow(2, i)) & 0x01) );

  printf("CIO default directions and states (byte 18):\n");
  for(i = 0; i <= 3; i++)
    printf("  CIO%d: %d and %d\n", i, ((recBuff[18]/(uint32)pow(2, 4 + i)) & 0x01), ((recBuff[18]/(uint32)pow(2, i)) & 0x01) );

  printf("MIO default directions and states (byte 19):\n");
  for(i = 0; i <= 2; i++)
    printf("  MIO%d: %d and %d\n", i, ((recBuff[19]/(uint32)pow(2, 4 + i)) & 0x01), ((recBuff[19]/(uint32)pow(2, i)) & 0x01) );
  
  printf("DAC0 default (bytes 20 and 21):\n  Enabled: %d\n", ((recBuff[21]/128) & 0x01) );

  //getting DAC0 binary value
  dac = (double)( (unsigned int)recBuff[20] + (((unsigned int)recBuff[21] & 15)*256) );  

  //getting DAC0 analog value (Volts = (Bits - Offset)/Slope )
  dac = (dac - caliInfo->DACOffset[0])/caliInfo->DACSlope[0];
  printf("  Voltage: %.3f V\n", dac);

  printf("DAC1 default (bytes 22 and 23):\n  Enabled: %d\n", ((recBuff[23]/128) & 0x01) );

  //getting DAC1 binary value
  dac = (double)( (uint32)recBuff[22] + ((recBuff[23] & 15)*256) );

  //getting DAC1 analog value ( Volts = (Bits - Offset)/Slope )
  dac = (dac - caliInfo->DACOffset[1])/caliInfo->DACSlope[1];
  printf("  Voltage: %.3f V\n\n", dac);

  return 0;
}
