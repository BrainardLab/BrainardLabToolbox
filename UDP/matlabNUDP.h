/* MATLABUDP.H
 *
 *	Header file for MATLABNUDP.c, which is 
 *  an adaptation of MATLABUDP.c to support multiple UDP connections
 *
 *
 *	NPC 27 Oct 2017
*/

#ifndef MATLABNUDP_H_
#define MATLABNUDP_H_

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>


#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/time.h>


#include <mex.h>

#define MAX_NUM_BYTES 2000

#define SATTELITES_NUM 5

//Globals for UDP socket
static int                      mat_UDP_sockfd[SATTELITES_NUM]= {-1},        //descriptor of UDP socket
                				mat_UDP_addr_len = sizeof(struct sockaddr),
                                mat_UDP_numBytes[SATTELITES_NUM];            //length of return message
                                
static char mat_UDP_messBuff[SATTELITES_NUM][MAX_NUM_BYTES];            //used by send and receive

static struct sockaddr_in       mat_UDP_LOCAL_addr;                     //holds LOCAL IP address 
static struct sockaddr_in       mat_UDP_REMOTE_addr[SATTELITES_NUM];     //holds REMOTE IP address(es)


//functions for exchanging strings with remote machines
void	mat_UDP_open	(char*, char*, int, int);            //initialize UDP socket
void	mat_UDP_send	(char*, int, int);                   //send a string to MATLAB
int     mat_UDP_check	(int);                         //is a return message available?
void	mat_UDP_read	(char*, int, int);                   //read any available message
void	mat_UDP_close	(int);                         //cleanup UDP socket
void	mat_UDP_close_all_ports (void);
        
void mexFunction(
    int           nlhs,           /* number of expected outputs */
    mxArray       *plhs[],        /* array of pointers to output arguments */
    int           nrhs,           /* number of inputs */
    const mxArray *prhs[]         /* array of pointers to input arguments */
    );


#endif /* MATLABUDP_H_ */
