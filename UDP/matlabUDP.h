/* MATLABUDP.H
 *
 *	Header file for MATLABUDP.c, which contains a few c-routines
 *	to be called from MATLAB so that dotsX machines can chat via
 *	ethernet and the UDP/IP protocols.
 *
 *  This is as close as possible to the code in matlabUDP.h on the
 *  REX machine.  The only real difference is that we have to implement
 *  the mexFunction interface for MATLAB.
 *
 *
 *	BSH 20 Jan 2006
*/

#ifndef MATLABUDP_H_
#define MATLABUDP_H_

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <Winsock2.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/time.h>
#endif

#include <mex.h>

#define MAX_NUM_BYTES 2000


//Globals for UDP socket
static int                      mat_UDP_sockfd=-1,      //descriptor of UDP socket
                				mat_UDP_addr_len        =sizeof(struct sockaddr),
                                mat_UDP_numBytes;       //length of return message
                                
static char mat_UDP_messBuff[MAX_NUM_BYTES];            //used by send and receive

static struct sockaddr_in       mat_UDP_LOCAL_addr,     //holds LOCAL IP address 
                                mat_UDP_REMOTE_addr;	//holds REMOTE IP address


//functions for exchanging strings with remote machines
void	mat_UDP_open	(char*, char*, int);            //initialize UDP socket
void	mat_UDP_send	(char*, int);                   //send a string to MATLAB
int     mat_UDP_check	(void);                         //is a return message available?
void	mat_UDP_read	(char*, int);                   //read any available message
void	mat_UDP_close	(void);                         //cleanup UDP socket

void mexFunction(
    int           nlhs,           /* number of expected outputs */
    mxArray       *plhs[],        /* array of pointers to output arguments */
    int           nrhs,           /* number of inputs */
    const mxArray *prhs[]         /* array of pointers to input arguments */
    );


#endif /* MATLABUDP_H_ */
