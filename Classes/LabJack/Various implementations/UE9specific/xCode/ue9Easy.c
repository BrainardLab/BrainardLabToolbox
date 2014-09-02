//Author: LabJack
//Oct. 8, 2007
//This examples demonstrates how to read from analog inputs (AIN) and digital inputs(FIO),
//set analog outputs (DAC) and digital outputs (FIO), and how to configure and enable
//timers and counters and read input timers and counters values using the "easy" functions.
#include "ue9.h"

const int ue9_port = 52360;

int main(int argc, char **argv)
{
  int socketFD, i;
  ue9CalibrationInfo caliInfo;
  long error;
  double dblVoltage;
  long lngState;
  long alngEnableTimers[6], alngTimerModes[6], alngEnableCounters[2], alngReadTimers[6];
  long alngUpdateResetTimers[6], alngReadCounters[2], alngResetCounters[2];
  double adblTimerValues[6], adblCounterValues[2];
  
  for(i = 0; i < 6; i++)
  {
    alngEnableTimers[i] = 0;
    alngTimerModes[i] = 0;
    adblTimerValues[i] = 0.0;
    alngReadTimers[i] = 0;
    alngUpdateResetTimers[i] = 0;
    if(i < 2)
    {
      alngEnableCounters[i] = 0;
      alngReadCounters[i] = 0;
      alngResetCounters[i] = 0;
      adblCounterValues[i] = 0.0;
    }
  }
  
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

  //Set DAC0 to 3.1 volts.
  printf("Calling eDAC to set DAC0 to 3.1 V\n");
  if((error = eDAC(socketFD, &caliInfo, 0, 3.1, 0, 0, 0)) != 0)
    goto close;


  //Read the voltage from AIN3 using 0-5 volt range at 12 bit resolution
  printf("Calling eAIN to read voltage from AIN3\n");
  if((error = eAIN(socketFD, &caliInfo, 3, 0, &dblVoltage, LJ_rgUNI5V, 12, 0, 0, 0, 0)) != 0)
    goto close;
  printf("\nAIN3 value = %.3f\n", dblVoltage);


  //Set FIO3 to output-high
  printf("\nCalling eDO to set FIO3 to output-high\n");
  if((error = eDO(socketFD, 3, 1)) != 0)
    goto close;


  //Read state of FIO2
  printf("\nCalling eDI to read the state of FIO2\n");
  if((error = eDI(socketFD, 2, &lngState)) != 0)
    goto close;
  printf("FIO2 state = %ld\n", lngState);


  //Enable and configure 1 output timer and 1 input timer, and enable counter0
  printf("\nCalling eTCConfig to enable and configure 1 output timer (Timer0) and 1 input timer (Timer1), and enable counter0\n");
  alngEnableTimers[0] = 1; //Enable Timer0
  alngEnableTimers[1] = 1; //Enable Timer1
  //Set timer modes
  alngTimerModes[0] = LJ_tmPWM8;
  alngTimerModes[1] = LJ_tmRISINGEDGES32;
  adblTimerValues[0] = 16384;  //Set PWM8 duty-cycles to 75%
  alngEnableCounters[0] = 1;  //Enable Counter0
  if((error = eTCConfig(socketFD, alngEnableTimers, alngEnableCounters, 0, LJ_tc750KHZ, 3, alngTimerModes, adblTimerValues, 0, 0)) != 0)
    goto close;

  printf("\nWaiting for 1 second...\n");
  #ifdef WIN32
    Sleep(1000);
  #else
    sleep(1);
  #endif

  //Read and reset the input timer (Timer1), read and reset Counter0, and update the
  //value (duty-cycle) of the output timer (Timer0)
  printf("\nCalling eTCValues to read and reset the input Timer1 and Counter0, and update the value (duty-cycle) of the output Timer0\n");
  alngReadTimers[1] = 1;  //Read Timer1
  alngUpdateResetTimers[0] = 1;  //Update timer0
  alngReadCounters[0] = 1;  //Read Counter0
  adblTimerValues[0] = 32768;  //Change Timer0 duty-cycle to 50%
  if((error = eTCValues(socketFD, alngReadTimers, alngUpdateResetTimers, alngReadCounters, alngResetCounters, adblTimerValues, adblCounterValues, 0, 0)) != 0)
    goto close;
  printf("Timer1 value = %.0f\n", adblTimerValues[1]);
  printf("Counter0 value = %.0f\n", adblCounterValues[0]);


  //Disable all timers and counters
  for(i = 0; i < 6; i++)
    alngEnableTimers[i] = 0;
  alngEnableCounters[0] = 0;
  alngEnableCounters[1] = 0;
  if((error = eTCConfig(socketFD, alngEnableTimers, alngEnableCounters, 0, 0, 0, alngTimerModes, adblTimerValues, 0, 0)) != 0)
    goto close;
  printf("\nCalling eTCConfig to disable all timers and counters\n");

close:
  if(error > 0)
    printf("Received an error code of %ld\n", error);
  if(closeTCPConnection(socketFD) < 0)
  {
    printf("Error: failed to close socket\n");
    return 1;
  }
done:
  return 0;
}
