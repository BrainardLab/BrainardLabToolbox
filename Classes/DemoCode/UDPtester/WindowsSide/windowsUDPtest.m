function windowsUDPtest

    
    macHostIP = '130.91.72.120';
    winHostIP = '130.91.74.15';
    udpPort = 2007;
    
    
    debug = false;
    if (debug)
        winHostIP = '130.91.72.17';  % IoneanPelagos
        macHostIP = '130.91.74.10';  % Manta
    end
    
    % Open up the UDP communication.
    matlabUDP('close');
    matlabUDP('open',winHostIP,macHostIP,udpPort);
    
    msgCount = 0;
    msg = '';
    while (~(strcmp(msg, 'quit')))
        msgCount = msgCount + 1;
        msg = input(sprintf('Message [%d] (''quit'' exits this loop): ', msgCount),'s');
        matlabUDP('send', msg);
    end
    matlabUDP('close');
end
