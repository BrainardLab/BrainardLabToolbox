function matlabNUDP_Satellite 
    satellite.ID = 0;
    
    satellite.portID = 2007;
    satellite.IP = '128.91.12.144'; % ionean
    localName = 'Ionean';
    %test(satellite, localName);   
    
    satellite.portID = 2008;
    satellite.IP = '128.91.12.155'; % leviathan
    localName = 'Leviathan';
    test(satellite, localName);   
 
    
end

function test(satellite, localName)
    fprintf('\n')
    
    baseIP = '128.91.12.90'; % manta

    
    matlabNUDP('close', satellite.ID);
    matlabNUDP('open', satellite.ID, satellite.IP, baseIP, satellite.portID);

    fprintf('Waiting to receive a message ...\n');
    while (matlabNUDP('check',  satellite.ID) ==0)
    end
    
    receivedMessage = matlabNUDP('receive',  satellite.ID)
    fprintf('Message received. Sending ACK\n');
    matlabNUDP('send', satellite.ID, sprintf('''%s'' sends ACK for: %s', localName, receivedMessage));
    matlabNUDP('close', satellite.ID);
end

