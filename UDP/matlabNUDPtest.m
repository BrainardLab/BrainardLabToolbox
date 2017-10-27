function matlabNUDPtest

    localIP = '128.91.12.90'; % manta
    remoteIP = '128.91.12.144'; % ionean
    portID = 2007;
    
    matlabNUDP('close');
    matlabNUDP('open', localIP, remoteIP, portUDP);

    disp('Hit enter to send a message\n');
    message = 'Hello from manta';
    matlabNUDP('send', message);
    
    disp('Hit enter to read a message\n');
    receivedMessage = matlabUDP('receive')
end

