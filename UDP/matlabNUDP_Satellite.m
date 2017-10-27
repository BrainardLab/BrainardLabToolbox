function matlabNUDP_Sattelite

    localIP = '128.91.12.144'; % ionean
    localName = 'Ionean';
    test(localIP, localName);   
    
    
%     localIP = '128.91.12.155'; % Leviathan
%     localName = 'Leviathan';
%     test(localIP, localName);   
    
end

function test(localIP, localName)
    fprintf('\n')
    
    remoteIP = '128.91.12.90'; % manta
    
    portID = 2007;
    
    matlabNUDP('close');
    matlabNUDP('open', localIP, remoteIP, portID);

    fprintf('Waiting to receive a message ...\n');
    while (matlabNUDP('check') ==0)
    end
    
    receivedMessage = matlabNUDP('receive')
    fprintf('Message received. Sending ACK\n');
    matlabNUDP('send', sprintf('''%s'' sends ACK for: %s', localName, receivedMessage));
    matlabNUDP('close');
end

