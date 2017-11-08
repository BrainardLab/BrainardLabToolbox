function matlabNUDP_Base

    baseIP = '128.91.12.90'; % manta
    
    satellite1.IP = '128.91.12.144'; % ionean
    satellite1.portID = 2007;
    satellite1.ID = 2;
    
    satellite2.IP = '128.91.12.155'; % leviathan
    satellite2.portID = 2008;
    satellite2.ID = 4;
    
    
    % Close satellites
    matlabNUDP('close', satellite1.ID);
    matlabNUDP('close', satellite2.ID);
    
    fprintf('Closed ports\n');
    
    
    % Open connections to 2 satellites
    matlabNUDP('open', satellite1.ID, baseIP, satellite1.IP, satellite1.portID);
    fprintf('Opened %s\n', satellite1.IP);
    
    matlabNUDP('open', satellite2.ID, baseIP, satellite2.IP, satellite2.portID);
    fprintf('Opened %s\n', satellite2.IP);
    
    disp('Hit enter to send a message\n');
    pause
    message = 'Hello from manta to Ionean';
    matlabNUDP('send', satellite1.ID, message);
    
    message = 'Hello from manta to Leviathan';
    matlabNUDP('send', satellite2.ID, message);
    
    disp('Hit enter to read a message\n');
    pause
    while (matlabNUDP('check', satellite1.ID) == 0)
    end
    receivedMessageFromIonean = matlabNUDP('receive', satellite1.ID)
    
    pause
    while (matlabNUDP('check', satellite2.ID) == 0)
    end
    receivedMessageFromLeviathan = matlabNUDP('receive', satellite2.ID)
    
    matlabNUDP('close', satellite1.ID);
    matlabNUDP('close', satellite2.ID);
end

