function matlabNUDP_Base

    baseIP = '128.91.12.90'; % manta
    
    sattelite1.IP = '128.91.12.144'; % ionean
    sattelite1.portID = 2007;
    sattelite1.ID = 2;
    
    sattelite2.IP = '128.91.12.155'; % leviathan
    sattelite2.portID = 2008;
    sattelite2.ID = 4;
    
    
    % Close sattelites
    matlabNUDP('close', sattelite1.ID);
    matlabNUDP('close', sattelite1.ID);
    
    % Open connections to 2 sattelites
    matlabNUDP('open', baseIP, sattelite1.ID, sattelite1.IP, sattelite1.portID);
    matlabNUDP('open', baseIP, sattelite2.ID, sattelite2.IP, sattelite2.portID);
    
    disp('Hit enter to send a message\n');
    pause
    message = 'Hello from manta to Ionean';
    matlabNUDP('send', sattelite1.ID, message);
    
    message = 'Hello from manta to Leviathan';
    matlabNUDP('send', sattelite2.ID, message);
    
    disp('Hit enter to read a message\n');
    pause
    while (matlabNUDP('check', sattelite1.ID) == 0)
    end
    receivedMessageFromIonean = matlabNUDP('receive', sattelite1.ID)
    
    pause
    while (matlabNUDP('check', sattelite2.ID) == 0)
    end
    receivedMessageFromLeviathan = matlabNUDP('receive', sattelite2.ID)
    
    matlabNUDP('close', sattelite1.ID);
    matlabNUDP('close', sattelite2.ID);
end

