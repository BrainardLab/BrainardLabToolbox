//Author: LabJack
//September 28, 2007
//This example program sends a CommConfig low-level command and reads the
//various configuration settings associated with the Comm processor.
#include "ue9.h"

const int ue9_port = 52360;

int commConfig_example(int socketFD);

int main(int argc, char **argv)
{
  int socketFD;

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
    return 1;

  commConfig_example(socketFD);

  if(closeTCPConnection(socketFD) < 0)
    printf("Error: failed to close socket\n");

  return 0;
}

//Sends a CommConfig low-level command to read the configuration settings
//associated with the Comm chip.
int commConfig_example(int socketFD)
{
  uint8 sendBuff[38];
  uint8 recBuff[38];
  int sendChars, recChars;
  int i, j;
  uint16 checksumTotal;
  char str[3];

  sendBuff[1] = (uint8)(0x78);  //command bytes
  sendBuff[2] = (uint8)(0x10);  //number of data words
  sendBuff[3] = (uint8)(0x01);  //extended command number

  //WriteMask, LocalID, PowerLevel, etc. are all passed a value of
  //zero since we only want to read Comm configuration settings,
  //not change them
  for(i = 6; i < 38; i++)
    sendBuff[i] = (uint8)(0x00);

  extendedChecksum(sendBuff, 38);

  //Sending command to UE9
  sendChars = send(socketFD, sendBuff, 38, 0);
  if(sendChars < 38)
  {
    if(sendChars == -1)
      printf("Error : send failed\n");
    else
      printf("Error : did not send all of the buffer\n");
    return -1;
  }

  //Receiving response from UE9
  recChars = recv(socketFD, recBuff, 38, 0);
  if(recChars < 38)
  {
    if(recChars == -1)
      printf("Error : receive failed\n");
    else  
      printf("Error : did not receive all of the buffer\n");
    return -1;
  }

  checksumTotal = extendedChecksum16(recBuff, 38);
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

  if( recBuff[1] != (uint8)(0x78) || recBuff[2] != (uint8)(0x10) || recBuff[3] != (uint8)(0x01) )
  {
    printf("Error : received buffer has wrong command bytes \n");
    return -1;
  }

  printf("LocalID (byte 8): %d\n", recBuff[8]);
  printf("PowerLevel (byte 9): %d\n", recBuff[9]);
  printf("ipAddress (bytes 10-13): %d.%d.%d.%d\n", recBuff[13], recBuff[12], recBuff[11], recBuff[10]);
  printf("Gateway (bytes 14 - 17): %d.%d.%d.%d\n", recBuff[17], recBuff[16], recBuff[15], recBuff[14]);
  printf("Subnet (bytes 18 - 21): %d.%d.%d.%d\n", recBuff[21], recBuff[20], recBuff[19], recBuff[18]);
  printf("PortA (bytes 22 - 23): %d\n", recBuff[22] + (recBuff[23] * 256 ));
  printf("PortA (bytes 24 - 25): %d\n", recBuff[24] + (recBuff[25] * 256 ));
  printf("DHCPEnabled (byte 26): %d\n", recBuff[26]);
  printf("ProductID (byte 27): %d\n", recBuff[27]);
  printf("MACAddress (bytes 28 - 33): ");

  for(i = 5; i >= 0  ; i--)
  {
    sprintf(str, "%x", (int)(recBuff[i+28]));

    for(j = 0; j < 3; j++)
    {
      if(str[j] == '\0')
        break;
    }

    if(j < 2)
    {
      str[1] = str[0];
      str[2] = '\0';
      str[0] = '0';
    }

    printf("%s", str);

    if(i > 2)
      printf(".");

    if(i == 2)
      printf(" ");
  }

  printf("\nHWVersion (bytes 34-35): %.3f\n", (unsigned int)recBuff[35]  + (double)recBuff[34]/100.0);
  printf("CommFWVersion (bytes 36-37): %.3f\n\n", (unsigned int)recBuff[37] + (double)recBuff[36]/100.0);

  return 0;
}
