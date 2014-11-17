Low-level UE9 C Examples for MAC OS X, Linux and Windows
August 8, 2008
support@labjack.com

This package contains example code (written in C) for calling low-level UE9
functions over a TCP connection.  The nine different example files included
are ue9allio.c, ue9CommConfig.c, ue9ControlConfig.c, ue9Easy.c, 
ue9Feedback.c, ue9LJTDAC.c, ue9SingleIO.c, ue9Stream.c, and 
ue9TimerCounter.c.  The files ue9.h and ue9.c contain functions that open 
and close a TCP connection, calculate checksums, get analog calibration 
information, and more.  When running the programs, enter the IP address of 
the UE9 on the command line.

To compile the programs:

Linux and MAC OS X:  From the command line, compile the programs by typing
'make'.  GCC will need to be installed in order to compile.

Windows:  Programs were compiled and tested using Visual Studio .NET.
Create an empty project and add ue9.c, ue9.h and one of the example files.
Link wsock32.lib to the project and build the project.  Run the programs
from a command line.
In the VS folder, there is an example project called ue9CommConfig.
