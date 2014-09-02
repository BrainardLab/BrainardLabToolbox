//Author: LabJack
//Oct. 2, 2007
//This example program calls the Feedback low-level function.  DAC0 will be set
//to 2.5 volts and DAC1 will be set to 3.5 volts.  The states and directions 
//will be read from FIO0 - FIO3 and the voltages (calibrated) from AI0-AI3.
#include "ue9.h"

const int ue9_port = 52360;

int feedback_example(int socketFD, ue9CalibrationInfo *caliInfo);

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
  if( (socketFD = openTCPConnection(argv[1], ue9_port)) < 0)
    goto done;

  //Getting calibration information from UE9
  if(getCalibrationInfo(socketFD, &caliInfo) < 0)
    goto close;

  feedback_example(socketFD, &caliInfo);

close:
  if(closeTCPConnection(socketFD)< 0)
    printf("Error: failed to close socket\n");
done:
  return 0;
}

//Sends a Feedback low-level command to set DAC0, DAC1, read FIO0-FIO3 and
//AI0-AI3.
int feedback_example(int socketFD, ue9CalibrationInfo *caliInfo)
{
  uint8 sendBuff[34], recBuff[64];
  int sendChars, recChars;
  double voltage;
  int i;
  unsigned int tempDir, tempState;
  uint16 checksumTotal, bytesVoltage;
  uint8 ainResolution, gainBip;

  ainResolution = 12;
  //ainResolution = 18;  //high-res mode for UE9 Pro only
  gainBip = 0;  //(Gain = 1, Bipolar = 0)

  sendBuff[1] = (uint8)(0xF8);  //command byte
  sendBuff[2] = (uint8)(0x0E);  //number of data words
  sendBuff[3] = (uint8)(0x00);  //extended command number

  //all these bytes are set to zero since we are not changing
  //the FIO, EIO, CIO and MIO directions and states
  for(i = 6; i <= 15; i++)
    sendBuff[i] = (uint8)(0x00);

  if(analogToCalibratedBinaryVoltage(caliInfo, 0, 2.500, &bytesVoltage) < 0)
    return -1;

  //setting the voltage of DAC0
  sendBuff[16] = (uint8)( bytesVoltage & (0x00FF) ); //low bits of voltage
  sendBuff[17] = (uint8)( bytesVoltage / 256 ) + 192; //high bits of voltage
                                                      //(bit 7 : Enable, bit 6: Update)
  if(analogToCalibratedBinaryVoltage(caliInfo, 1, 3.500, &bytesVoltage) < 0)
    return -1;

  //setting the voltage of DAC1
  sendBuff[18] = (uint8)( bytesVoltage & (0x00FF) ); //low bits of voltage
  sendBuff[19] = (uint8)( bytesVoltage / 256 ) + 192; //high bits of voltage
                                                     //(bit 7 : Enable, bit 6: Update)
  sendBuff[20] = (uint8)(0x0f);  //AINMask - reading AIN0 - AIN3, not AIN4 - AIN7
  sendBuff[21] = (uint8)(0x00);  //AINMask - not reading AIN8 - AIN15
  sendBuff[22] = (uint8)(0x00);  //AIN14ChannelNumber - not using
  sendBuff[23] = (uint8)(0x00);  //AIN15ChannelNumber - not using
  sendBuff[24] = ainResolution;     //Resolution = 12

  //setting BipGains
  for(i = 25; i < 34; i++)
    sendBuff[i] = gainBip;

  extendedChecksum(sendBuff, 34);

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, 34, 0);
  if(sendChars < 34)
  {
    if(sendChars == -1)
      printf("Error : send failed\n");
    else
      printf("Error : did not send all of the buffer\n");
    return -1;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 64, 0);
  if(recChars < 64)
  {
    if(recChars == -1)
      printf("Error : recv failed\n");
    else
      printf("Error : did not receive all of the buffer\n");
    return -1;
  }

  checksumTotal = extendedChecksum16(recBuff, 64);
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

  if(recBuff[1] != (uint8)(0xF8) || recBuff[2] != (uint8)(0x1D) || recBuff[3] != (uint8)(0x00))
  {
    printf("Error : received buffer has wrong command bytes \n");
    return -1;
  }

  printf("Set DAC0 to 2.500 volts and DAC1 to 3.500 volts.\n\n");
  printf("Flexible digital I/O directions and states (FIO0 - FIO3):\n");
  for(i = 0; i < 4; i++)
  {
    tempDir = ( (uint32)(recBuff[6] / pow(2, i)) & 0x01 );
    tempState = ( (uint32)(recBuff[7] / pow(2, i)) & 0x01 );
    printf("  FI%d: %d and %d\n", i, tempDir, tempState);
  }

  printf("\nAnalog Inputs (AI0 - AI3):\n");
  for(i = 0; i < 4; i++)
  {
    bytesVoltage = recBuff[12 + 2*i] + recBuff[13 + 2*i] * 256;

    //getting analog voltage
    if(binaryToCalibratedAnalogVoltage(caliInfo, gainBip, ainResolution, bytesVoltage, &voltage) < 0)
      return -1;

    printf("  AI%d: %.6f V\n", i, voltage);
  }
  printf("\n");

  return 0;
}
