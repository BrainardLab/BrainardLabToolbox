function receiveStructPackages
    %tbUse({'BrainardLabToolbox', 'UnitTestToolbox'});
    
    % Open UDP channel
    localHost = '128.91.12.144';
    remoteHost = '128.91.12.90';
    matlabUDP('open', localHost, remoteHost, 2007);
    
    % Wait until we receive 10 packets
    dataPackets = 10;
    
    dataCounter = 0;
    while (dataCounter < dataPackets) 
        fprintf('Waiting to receive serialized data\n');
        waitForNewDataArrival();

        tic
        % Check for struct_transmit_initiate token
        token = matlabUDP('receive');
        if (~strcmp(token,'struct_transmit_initiate'))
            error('Did not receive ''struct_transmit_initiate'' message');
        end
        
        % Obtain serialized object bytes
        waitForNewDataArrival();
        bytesString = matlabUDP('receive');
        numBytes = str2double(bytesString);
        fprintf('Will read %d char\n', numBytes);
        
        % Read all bytes
        theData = [];
        for k = 1:numBytes
            waitForNewDataArrival();
            theData(k) = str2double(matlabUDP('receive'));
        end

        % Check for struct_transmit_terminate token
        waitForNewDataArrival();
        token = matlabUDP('receive');
        if (~strcmp(token,'struct_transmit_terminate'))
            error('Did not receive ''struct_transmit_terminate'' message');
        end
        
        % Reconstruct object
        theStruct = getArrayFromByteStream(uint8(theData));
       
        dataCounter = dataCounter + 1;
        times(dataCounter) = toc;
        disp(UnitTest.displayNicelyFormattedStruct(theStruct, sprintf('s(%d)', dataCounter), '', 50));
        
        theImages{dataCounter} = theStruct.image;
    end
    
    % Close UDP channel
    matlabUDP('close')
    
    mean(times)
    
    % Display images transmitted
    figure(1); clf;
    for k = 1:numel(theImages)
        subplot(2,5,k);
        imagesc(theImages{k});
        colormap(gray)
        axis 'image'
    end
    
   
end

function waitForNewDataArrival()
    while (~matlabUDP('check'))
    end
end


