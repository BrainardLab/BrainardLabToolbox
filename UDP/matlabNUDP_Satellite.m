function matlabNUDP_Sattelite

    
    sattelite.portID = 2007;
    sattelite.ID = 0;
    
    sattelite.IP = '128.91.12.144'; % ionean
    localName = 'Ionean';
    test(sattelite, localName);   
    
    
%    sattelite.IP = '128.91.12.155'; % leviathan
%    localName = 'Leviathan';
%    test(sattelite, localName);   
 
    
end

function test(sattelite, localName)
    fprintf('\n')
    
    baseIP = '128.91.12.90'; % manta

    
    matlabNUDP('close', sattelite.ID);
    matlabNUDP('open', sattelite.ID, sattelite.IP, baseIP, sattelite.portID);

    fprintf('Waiting to receive a message ...\n');
    while (matlabNUDP('check',  sattelite.ID) ==0)
    end
    
    receivedMessage = matlabNUDP('receive',  sattelite.ID)
    fprintf('Message received. Sending ACK\n');
    matlabNUDP('send', sattelite.ID, sprintf('''%s'' sends ACK for: %s', localName, receivedMessage));
    matlabNUDP('close', sattelite.ID);
end

