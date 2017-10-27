/* MATLABNUDP.C
 *
 *	MATLABNUDP.c An adaptation of MATLABUDP.c to support multiple UDP connections
 *
 *
 *	NPC 27 Oct 2017
 */

#include "matlabNUDP.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char *command=NULL;
    char local[16], remote[16];
    int buf_len;
    size_t dims[2];
    int i;
    unsigned short *outPtr;
    int satteliteID;
    
    // If no arguments given, print usage string
    if(nrhs < 2) {
        mexPrintf("matlabNUDP usage:\n socketIsOpen = matlabNUDP('open',  (int)satteliteID, (string)localIP, (string)remoteIP, (int)port);%% should return small int\n matlabNUDP('send', (int)satteliteID, (string)message);\n messageIsAvailable = matlabNUDP('check', (int)satteliteID);\n message = matlabNUDP('receive', (int)satteliteID);\n socketIsOpen = matlabNUDP('close', (int)satteliteID);%% should return -1\n");
        return;
    }
    
    // First argument is command string... get and convert to char *
    if(mxGetM(prhs[0]) == 1 && mxGetN(prhs[0]) >= 1 && mxIsChar(prhs[0])) {
        buf_len =  mxGetN(prhs[0]) + 1;
        command = mxCalloc(buf_len, sizeof(char));
        if(mxGetString(prhs[0], command, buf_len))
            mexWarnMsgTxt("matlabNUDP: Not enough heap space. String (command) is truncated.");
    } else {
        mexErrMsgTxt("matlabNUDP: First argument should be a string (command).");
    }
    
    // Second argument if the satteliteID
    satteliteID = (int)(mxGetScalar(prhs[1]));
    //mexPrintf("Operating on satteliteID: %d\n", satteliteID);
    
    // case on command string...
    if(!strncmp(command, "open", 3)) {
        // done with command
        mxFree(command);
        
        // register exit routine to free socket
        if(mexAtExit(mat_UDP_close_all_ports) != 0 ) {
            mat_UDP_close_all_ports();
            mexErrMsgTxt("matlabNUDP: failed to register exit routine, mat_UDP_close.");
        }
        
        // only open a fresh socket if
        //  PORT arg is a number, and
        //  IP addr args are short strings e.g. "111.222.333.444"
        if(nrhs==5 && mxIsNumeric(prhs[4])
        && mxIsChar(prhs[3]) && mxGetN(prhs[3])<=15
        && mxIsChar(prhs[2]) && mxGetN(prhs[2])<=15){

            // close old socket?
            if(mat_UDP_sockfd[satteliteID]>=0)
                mat_UDP_close(satteliteID);
            
            //format args for socket opener function
            mxGetString(prhs[2],local,16);
            mxGetString(prhs[3],remote,16);

            //openerup
            mexPrintf("matlabNUDP opening socket for satteliteID: %d\n", satteliteID);
            mat_UDP_open(local, remote, (int)mxGetScalar(prhs[4]), satteliteID);
            
        }
        
        // always return socket index

        // build me a return value worthy of MATLAB
        if(!(plhs[0] = mxCreateDoubleScalar((double)mat_UDP_sockfd[satteliteID])))
            mexErrMsgTxt("matlabNUDP: mxCreateNumericArray failed.");
        
        
    } else if(!strncmp(command, "receive", 3)) {
        
        // done with command
        mxFree(command);
        
        dims[0] = 1;
        
        if(nlhs<=1){
            
            if(mat_UDP_sockfd[satteliteID]<0){

                // socket closed so zero bytes are read
                i = 0;

            } else {
                
                // read new bytes from socket
                mat_UDP_read(mat_UDP_messBuff[satteliteID], MAX_NUM_BYTES, satteliteID);//sets mat_UDP_numBytes[satteliteID]
                i = mat_UDP_numBytes[satteliteID];

            }

            // always provide at least an empty return value
            dims[1] = i;
            if(!(plhs[0] = mxCreateCharArray((size_t) 2, dims)))
                mexErrMsgTxt("matlabNUDP: mxCreateCharArray failed.");
            
            // fill in report with any new bytes
            outPtr = (unsigned short *) mxGetData(plhs[0]);
            for(i--; i>=0; i--){
                *(outPtr + i) = mat_UDP_messBuff[satteliteID][i];
            }

        }

        
    } else if(!strncmp(command, "send", 3)) {
        
        // done with command
        mxFree(command);
        
        if(mat_UDP_sockfd[satteliteID]<0){
            
            // warn that no message was not sent
            mexWarnMsgTxt("matlabNUDP: Message not sent.  No socket is open.");
            
        } else {
            
            // only send message if message arg is a 1-by-N char array
            if(nrhs==3 && mxIsChar(prhs[2]) && mxGetM(prhs[2])==1 && mxGetN(prhs[2])>0){
                
                // format ye string and send forth
                mxGetString(prhs[2],mat_UDP_messBuff[satteliteID],mxGetN(prhs[2])+1);
                mat_UDP_send(mat_UDP_messBuff[satteliteID], mxGetN(prhs[2]), satteliteID);
                
            }else{
                
                // warn that no message was not sent
                mexWarnMsgTxt("matlabNUDP: Message not sent.  Must be 1-by-N char array.");
                
            }
        }

        
    } else if(!strncmp(command, "check", 3)) {
        
        // done with command
        mxFree(command);
        
        // always provide a return value
        // if socket is closed, && will short-circuit and skip the actual socket check
        if(!(plhs[0] = mxCreateDoubleScalar( (double) (mat_UDP_sockfd[satteliteID]>=0) && mat_UDP_check(satteliteID) )))
            mexErrMsgTxt("matlabNUDP: mxCreateNumericArray failed.");
        
        
    } else if(!strncmp(command, "close", 3)) {
        
        // done with command
        mxFree(command);

        // only try to close if socket is open
        if(mat_UDP_sockfd[satteliteID] >= 0)
            mat_UDP_close(satteliteID);
        
        // always return socket index
        if(nlhs==1){
            if(!(plhs[0] = mxCreateDoubleScalar((double)mat_UDP_sockfd[satteliteID])))
                mexErrMsgTxt("matlabNUDP: mxCreateNumericArray failed.");
        }
        
        
    } else {
        
        // done with command
        mxFree(command);
        
        mexWarnMsgTxt("matlabNUDP: Unknown command option");
    }
}

//initialize UDP socket
void mat_UDP_open (char localIP[], char remoteIP[], int port, int satteliteID){    
    mat_UDP_REMOTE_addr[satteliteID].sin_family = AF_INET;	// host byte order
    mat_UDP_REMOTE_addr[satteliteID].sin_port = htons(port);	// short, network byte order
    mat_UDP_REMOTE_addr[satteliteID].sin_addr.s_addr = inet_addr(remoteIP);
    memset(&(mat_UDP_REMOTE_addr[satteliteID].sin_zero), '\0', 8);// zero the rest of the struct
    
    mat_UDP_LOCAL_addr.sin_family = AF_INET;         // host byte order
    mat_UDP_LOCAL_addr.sin_port = htons(port);     // short, network byte order
    mat_UDP_LOCAL_addr.sin_addr.s_addr = inet_addr(localIP);
    memset(&(mat_UDP_LOCAL_addr.sin_zero), '\0', 8); // zero the rest of the struct
    
    //mexPrintf("localIP = <%s>\n",inet_ntoa(mat_UDP_LOCAL_addr.sin_addr));
    //mexPrintf("remoteIP = <%s>\n",inet_ntoa(mat_UDP_REMOTE_addr.sin_addr));
    //mexPrintf("ports = <%i>,<%i>\n",mat_UDP_LOCAL_addr.sin_port,mat_UDP_REMOTE_addr.sin_port  );
    
    if ((mat_UDP_sockfd[satteliteID]=socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        mexErrMsgTxt("Couldn't create UDP socket.");
    }
    
    //mexPrintf("sockFD = %i\n",mat_UDP_sockfd);
    
    if (bind(mat_UDP_sockfd[satteliteID], (struct sockaddr *)&mat_UDP_LOCAL_addr, mat_UDP_addr_len) == -1){
        mexErrMsgTxt("Couldn't bind socket.  Maybe invalid local address.");
    }
}


//send a string to MATLAB
void mat_UDP_send (char mBuff[], int mLen, int satteliteID){
    
    //     const char drPhil[] = {"you're a loser"};
    //     int callyourwifeabitch = 11;
    //     int youreabigfatgooneybird = 0;
    //
    //     youreabigfatgooneybird=sendto(mat_UDP_sockfd, drPhil, callyourwifeabitch, MSG_DONTWAIT,(struct sockaddr *)&mat_UDP_REMOTE_addr, mat_UDP_addr_len);
    //     mexPrintf("loser=<%s>, loserLen=%i, retVal=%i\n",drPhil,callyourwifeabitch,youreabigfatgooneybird);
    
    if ((mLen=sendto(mat_UDP_sockfd[satteliteID], mBuff, mLen, MSG_DONTWAIT,
    (struct sockaddr *)&mat_UDP_REMOTE_addr[satteliteID], mat_UDP_addr_len)) == -1)
        mexWarnMsgTxt("Couldn't send string.  Are computers connected??");
}


//is a return message available?
int mat_UDP_check (int satteliteID){
    static struct timeval timout;
    static fd_set readfds;
    FD_ZERO(&readfds);
    FD_SET(mat_UDP_sockfd[satteliteID],&readfds);
    select(mat_UDP_sockfd[satteliteID]+1,&readfds,NULL,NULL,&timout);
    return(FD_ISSET(mat_UDP_sockfd[satteliteID],&readfds));
}


//read any available message
void mat_UDP_read (char mBuff[], int messUpToLen, int satteliteID){
    if ((mat_UDP_numBytes[satteliteID]=recvfrom(mat_UDP_sockfd[satteliteID],mBuff, messUpToLen, MSG_DONTWAIT,
    (struct sockaddr *)&(mat_UDP_REMOTE_addr[satteliteID]), &mat_UDP_addr_len)) <0 )
        mat_UDP_numBytes[satteliteID]=0;
}

//cleanup UDP socket
void mat_UDP_close (int satteliteID){
    if(mat_UDP_sockfd[satteliteID]>=0){
        mexPrintf("matlabNUDP closing socket to sattelite %d\n", satteliteID);
        close(mat_UDP_sockfd[satteliteID]);
        mat_UDP_sockfd[satteliteID]=-1;
    }
}

//cleanup UDP socket
void mat_UDP_close_all_ports (void){
    for (int satteliteID = 0; satteliteID < SATTELITES_NUM; satteliteID++) {
    if(mat_UDP_sockfd[satteliteID]>=0){
        mexPrintf("matlabNUDP closing socket to sattelite %d\n", satteliteID);
        close(mat_UDP_sockfd[satteliteID]);
        mat_UDP_sockfd[satteliteID]=-1;
    }
    }
}

