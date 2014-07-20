//Author: LabJack
//Oct. 4, 2007
//Communicates with an LJTick-DAC using low level functions.  The LJTDAC should
//be plugged into FIO0/FIO1 for this example.
//Tested with UE9 Comm firmware V1.43 and Control firmware V1.84.

#include "ue9.h"

int checkI2CErrorcode(uint8 errorcode);
int LJTDAC_example(int socketFD, ue9LJTDACCalibrationInfo *caliInfo);

const int ue9_port = 52360;
const uint8 SCLPinNum = 0;

int main(int argc, char **argv)
{
  int socketFD;
  ue9LJTDACCalibrationInfo caliInfo;

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

  //Getting calibration information from LJTDAC
  if(getLJTDACCalibrationInfo(socketFD, &caliInfo, SCLPinNum) < 0)
    goto close;

  LJTDAC_example(socketFD, &caliInfo);

close:
  if(closeTCPConnection(socketFD) < 0)
  {
    printf("Error: failed to close socket\n");
    return 1;
  }
done:
  return 0;
}


int checkI2CErrorcode(uint8 errorcode)
{
  if(errorcode != 0)
  {
    printf("I2C error : received errorcode %d in response\n", errorcode);
    return -1;
  }
  return 0;
}


int LJTDAC_example(int socketFD, ue9LJTDACCalibrationInfo *caliInfo)
{
  int err;
  uint8 options, speedAdjust, sdaPinNum, sclPinNum;
  uint8 addressByte, numBytesToSend, numBytesToReceive, errorcode;
  uint16 binaryVoltage;
  uint8 bytesCommand[5];
  uint8 bytesResponse[64];
  uint8 ackArray[4];
  int i;

  err = 0;

  //Setting up parts I2C command that will remain the same throughout this example
  options = 0;             //I2COptions : 0
  speedAdjust = 0;         //SpeedAdjust : 0 (for max communication speed of about 130 kHz)
  sdaPinNum = SCLPinNum + 1;  //SDAPinNum : FIO1 connected to pin DIOB
  sclPinNum = SCLPinNum;      //SCLPinNum : FIO0 connected to pin DIOA


  /* Set DACA to 1.2 volts. */

  //Setting up I2C command
  //Make note that the I2C command can only update 1 DAC channel at a time.
  addressByte = (uint8)(0x24);  //AddressByte : h0x24 is the address byte for DAC

  numBytesToSend = 3;       //NumI2CByteToSend : 3 bytes to specify DACA and the value
  numBytesToReceive = 0;    //NumI2CBytesToReceive : 0 since we are only setting the value of the DAC
  bytesCommand[0] = (uint8)(0x30);  //LJTDAC command byte : h0x30 (DACA)
  LJTDACAnalogToCalibratedBinaryVoltage(caliInfo, 0, 1.2, &binaryVoltage);
  bytesCommand[1] = (uint8)(binaryVoltage/256);          //value (high)
  bytesCommand[2] = (uint8)(binaryVoltage & (0x00FF));   //value (low)

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  printf("DACA set to 1.2 volts\n\n");


  /* Set DACB to 2.3 volts. */

  //Setting up I2C command
  addressByte = (uint8)(0x24);  //AddressByte : h0x24 is the address byte for DAC
  numBytesToSend = 3;       //NumI2CByteToSend : 3 bytes to specify DACB and the value
  numBytesToReceive = 0;    //NumI2CBytesToReceive : 0 since we are only setting the value of the DAC
  bytesCommand[0] = (uint8)(0x31);  //LJTDAC command byte : h0x31 (DACB)
  LJTDACAnalogToCalibratedBinaryVoltage(caliInfo, 1, 2.3, &binaryVoltage);
  bytesCommand[1] = (uint8)(binaryVoltage/256);          //value (high)
  bytesCommand[2] = (uint8)(binaryVoltage & (0x00FF));   //value (low)

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  printf("DACB set to 2.3 volts\n\n");


  /* More advanced operations. */

  /* Display LJTDAC calibration constants.  Code for getting the calibration constants is in the
   * getLJTDACCalibrationInfo function in the ue9.c file. */
  printf("DACA Slope = %.1f bits/volt\n", caliInfo->DACSlopeA);
  printf("DACA Offset = %.1f bits\n", caliInfo->DACOffsetA);
  printf("DACB Slope = %.1f bits/volt\n", caliInfo->DACSlopeB);
  printf("DACB Offset = %.1f bits\n\n", caliInfo->DACOffsetB);


  /* Read the serial number. */

  //Setting up I2C command
  addressByte = (uint8)(0xA0);  //AddressByte : h0xA0 is the address byte for EEPROM
  numBytesToSend = 1;       //NumI2CByteToSend : 1 byte for the EEPROM address
  numBytesToReceive = 4;    //NumI2CBytesToReceive : getting 4 bytes starting at EEPROM address specified in I2CByte0
  bytesCommand[0] = 96;     //I2CByte0 : Memory Address, starting at address 96 (Serial Number)

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  printf("LJTDAC Serial Number = %u\n\n", (bytesResponse[0] + bytesResponse[1]*256 + bytesResponse[2]*65536 + bytesResponse[3]*16777216));


  /* User memory example.  We will read the memory, update a few elements,
   * and write the memory. The user memory is just stored as bytes, so almost
   * any information can be put in there such as integers, doubles, or strings. */

  /* Read the user memory */

  //Setting up I2C command
  addressByte = (uint8)(0xA0);  //AddressByte : h0xA0 is the address byte for EEPROM
  numBytesToSend = 1;       //NumI2CByteToSend : 1 byte for the EEPROM address
  numBytesToReceive = 64;   //NumI2CBytesToReceive : getting 64 bytes starting at EEPROM address specified in I2CByte0
  bytesCommand[0] = 0;      //I2CByte0 : Memory Address, starting at address 0 (User Area)

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  //Display the first 4 elements.
  printf("Read User Mem [0-3] = %d, %d, %d, %d\n", bytesResponse[0], bytesResponse[1], bytesResponse[2], bytesResponse[3]);


  /* Create 4 new pseudo-random numbers to write.  We will update the first
   * 4 elements of user memory, but the rest will be unchanged. */

  //Setting up I2C command
  addressByte = (uint8)(0xA0);  //AddressByte : h0xA0 is the address byte for EEPROM
  numBytesToSend = 5;       //NumI2CByteToSend : 1 byte for the EEPROM address and the rest for the bytes to write
  numBytesToReceive = 0;    //NumI2CBytesToReceive : 0 since we are only writing to memory
  bytesCommand[0] = 0;      //I2CByte0 : Memory Address, starting at address 0 (User Area)
  srand((unsigned int)getTickCount());
  for(i = 1; i < 5; i++)
    bytesCommand[i] = (uint8)(255*((float)rand()/RAND_MAX));;  //I2CByte : byte in user memory

  printf("Write User Mem [0-3] = %d, %d, %d, %d\n", bytesCommand[1], bytesCommand[2], bytesCommand[3], bytesCommand[4]);

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  //Delay for 2 ms to allow the EEPROM to finish writing.
  //Re-read the user memory.
  #ifdef WIN32
    Sleep(2);
  #else
    usleep(2000);
  #endif

  //Setting up I2C command
  addressByte = (uint8)(0xA0);  //AddressByte : h0xA0 is the address byte for EEPROM
  numBytesToSend = 1;       //NumI2CByteToSend : 1 byte for the EEPROM address
  numBytesToReceive = 64;   //NumI2CBytesToReceive : getting 64 bytes starting at EEPROM address specified in I2CByte0
  bytesCommand[0] = 0;      //I2CByte0 : Memory Address, starting at address 0 (User Area)

  //Performing I2C low-level call
  err = I2C(socketFD, options, speedAdjust, sdaPinNum, sclPinNum, addressByte, numBytesToSend, numBytesToReceive, bytesCommand, &errorcode, ackArray, bytesResponse);

  if(checkI2CErrorcode(errorcode) == -1 || err == -1)
    return -1;

  //Display the first 4 elements.
  printf("Read User Mem [0-3] = %d, %d, %d, %d\n", bytesResponse[0], bytesResponse[1], bytesResponse[2], bytesResponse[3]);

  return err;
}
