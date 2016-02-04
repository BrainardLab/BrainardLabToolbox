function macUDPtest

    macHostIP = '130.91.72.120';
    winHostIP = '130.91.74.15';
    udpPort = 2007;
    
    debug = true;
    if (debug)
        winHostIP = '130.91.72.17';  % IoneanPelagos
        macHostIP = '130.91.74.10';  % Manta
    end
    
    % Open up the UDP communication.
    matlabUDP('close');
    matlabUDP('open',macHostIP,winHostIP,udpPort);
    
    msg = 'none';
    msgCount = 0;
    fprintf('\n');
    while(~(strcmp(msg, 'quit')))
        fprintf('Waiting for Windoze computer to send something ...\n');
        while matlabUDP('check') == 0; end
        msg = matlabUDP('receive');
        msgCount = msgCount+1;
        fprintf('[%d]. Received ''%s\n'' .', msgCount, msg);
    end

end
