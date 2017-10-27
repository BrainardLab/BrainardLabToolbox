function matlabNUDPtest

    baseIP = '128.91.12.90'; % manta
    
    sattelite1.IP = '128.91.12.144'; % ionean
    sattelite1.portID = 2007;
    satellite1.ID = 2;
    
    
    matlabNUDP('close', satellite1.ID);
    matlabNUDP('open', baseIP, satellite1.ID, sattelite1.IP, sattelite1.portID);

    disp('Hit enter to send a message\n');
    pause
    message = 'Hello from manta';
    matlabNUDP('send', satellite1.ID, message);
    
    disp('Hit enter to read a message\n');
    pause
    while (matlabNUDP('check', satellite1.ID) == 0)
    end
    receivedMessage = matlabNUDP('receive', satellite1.ID)
    matlabNUDP('close', satellite1.ID);
end

