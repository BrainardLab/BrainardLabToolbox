function times = testUE9
    
    addpath(genpath('.'));
    
    % The LABJACKstruct is set by connectToLabJack
    global LABJACKstruct
    status = connectToLabJack();

    if (status ~= 0) 
        h = msgbox('Could not connect to a LabJack device !!!');
        uiwait(h); 
        return;
    end
    
    LABJACKstruct
    
    if (~LABJACKstruct.devicePointerIsValid)
        h = msgbox('LabJack device pointer is not valid !!!');
        uiwait(h); 
        return;
    end
    
        
    N = 50 * 1000;
    times = zeros(N,1);
    for i = 1:N
        
        % must be between 0 and 65535 (16-lines)
        decimalValue = uint16(mod(i, 65535));

        tic
        % Send the desired uint16 value
        binaryVector = dec2bin(decimalValue,16);                                % Create a 16-bit word to represent the decimal Value                     
        bitStates    = uint8(binaryVector)-uint8('0');                          % valid options are:  0 = LOW    1 = HIGH 
        
        status       = setDigitalLines(LABJACKstruct.DIO16bitChannelArrangement, bitStates);
        times(i) = toc*1000;
        
        if (status ~= 0)
            disp('failed to set 16-bit digital lines');
            return;
        end
    end
     
    
    [mindt, index_of_min] = min(times);
    [maxdt, index_of_max] = max(times);
    [maxdt2, index_of_max2] = max(times(2:end));
    
    fprintf('min dt: %2.4f msecs (%d entry)\n',mindt, index_of_min);
    fprintf('max dt: %2.4f msecs (%d entry)\n', maxdt, index_of_max);
    fprintf('max(2:end) dt: %2.4f msecs (%d entry)\n', maxdt2, index_of_max2);
    fprintf('mean dt: %2.4f msecs\n', mean(times));
   
    
    closeLabJack();
    
    h = figure(1);
    set(h, 'Position', [1000 90 500 980]);
    bin_centers = [floor(mindt):0.1:ceil(maxdt2)];
    subplot('Position', [0.06 0.06 0.93 0.93]);
    hist(times(2:end), bin_centers);
    h2 = findobj(gca,'Type','patch');
    set(h2,'FaceColor',[.9 .2 .5],'EdgeColor','w');
    xlabel('Time between DIO commands (msec)', 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'bold');
    ylabel('count', 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16, 'FontWeight', 'bold')
    set(gca, 'XLim', [floor(mindt) ceil(maxdt2)], 'YLim', [-0.1 1000]);
    set(gcf, 'Color', 'w')
end


function status = setDigitalLines(channelIDs, bitStates)
    
    sendDataMessage             = zeros(2*length(channelIDs),1, 'uint8');
    
    indices                     = 1+2*[0:length(channelIDs)-1];
    
    sendDataMessage(indices)    = 11;              % IOType is BitStateWrite
    sendDataMessage(indices+1)  = channelIDs + 128*bitStates;
    
    status = sendLowLevelCommand(sendDataMessage);
end


function status = sendLowLevelCommand(dataMessage)
    
    global LABJACKstruct

    status      = 0;
    
 
    sendMessageLength       = 34;
    receiveMessageLength    = 64;


    sendMessage    = zeros(1, sendMessageLength, 'uint8');

    sendMessage(2) = uint8(hex2dec('F8'));   % Command byte
    sendMessage(3) = uint8(hex2dec('0E'));   % Number of data words 
    sendMessage(4) = uint8(hex2dec('00'));   % Extended command number


    DIOchannelsNum  = length(dataMessage)/2;
    states          = zeros(1, DIOchannelsNum, 'uint8');
    channelIDs      = zeros(1, DIOchannelsNum, 'uint8');

    %fprintf('\n State: ');
    for channelIndex = 1:DIOchannelsNum
        % ignore the odd number bytes sendDataMessage(1 + 2*(channelIndex-1))  = 13;
        evenByteNumber = dataMessage(2 + 2*(channelIndex-1));

        states(channelIndex)      = floor(evenByteNumber/128);  % 1 or 0
        channelIDs(channelIndex)  = evenByteNumber - states(channelIndex)*128;

    end  % for channelIndex



    multiplier = uint8(2.^[7:-1:0]);
    sendMessage(7) = uint8(hex2dec('FF'));   % all FIOs
    sendMessage(8) = uint8(hex2dec('FF'));   % all FIOs are output channels
    sendMessage(9) = uint8(sum(states(9:16) .* multiplier));


    sendMessage(10) = uint8(hex2dec('FF'));   % all EIOs
    sendMessage(11) = uint8(hex2dec('FF'));   % all EIOs are output channels
    sendMessage(12) = uint8(sum(states(1:8) .* multiplier));

    % Calculate and set the checksum16
    checksum16          = calculateChecksum16(sendMessage,sendMessageLength);
    sendMessage(5)      = uint8(bitand(checksum16, hex2dec('FF')));
    sendMessage(6)      = uint8(bitand(bitshift(checksum16,-8), hex2dec('FF')));

    % Calculate and set the checksum8
    sendMessage(1)      = calculateChecksum8(sendMessage);
        
        
    
    sendBuffer   = libpointer('uint8Ptr', sendMessage);
    bytesWritten = calllib('liblabjackusb', 'LJUSB_Write', LABJACKstruct.devicePointer , sendBuffer, sendMessageLength);
    
    
    if (bytesWritten ~= sendMessageLength)
        disp('An error occurred while trying to write to the Device.');
        status = -1;
        return;
    end
    
    
    % Read the result from the device.
   
    
    receiveMessage  = zeros(receiveMessageLength, 1, 'uint8');
    receiveBuffer   = libpointer('uint8Ptr', receiveMessage);
    
    bytesRead       = calllib('liblabjackusb', 'LJUSB_Read', LABJACKstruct.devicePointer, receiveBuffer, receiveMessageLength);
    
    receiveMessage = get(receiveBuffer, 'value');
    
    if (bytesRead == -1)
        disp('Read Failed');
        status = -1;
        return;
        
    elseif (bytesRead < 8)
        fprintf('ehFeedback error : response buffer is too small; expected %d, received %d\n', receiveMessageLength, bytesRead);
        status = -1;
        return;
        
    elseif (bytesRead < receiveMessageLength) 
        fprintf('An error occurred while trying to read from the Device. Bytes expected: %d; Received: %d', receiveMessageLength, bytesRead);
        
    end
    
    
    checksumTotal = calculateChecksum16(receiveMessage, receiveMessageLength);
    
    
    if (uint8( bitand( bitshift(checksumTotal,-8), hex2dec('FF')) ) ~= receiveMessage(6) )

        printf('ehFeedback error : received buffer has bad checksum16(MSB)\n');
        status = -1;
        return;
    end


    if ( uint8(bitand(checksumTotal, hex2dec('FF'))) ~= receiveMessage(5) )
        printf('ehFeedback error : received buffer has bad checksum16(LSB)\n');
        status = -1;
        return;
    end


    if ( calculateChecksum8(receiveMessage) ~= receiveMessage(1) )
        printf('ehFeedback error : read buffer has bad checksum8\n');
        status = -1;
        return;
    end
        
        
        
    if ( (receiveMessage(2) ~= uint8(hex2dec('F8')) ) || (receiveMessage(3) ~= uint8(hex2dec('1D')) ) || (receiveMessage(4) ~= uint8(hex2dec('00')) ) ) 
        printf('ehFeedback error :  read buffer has wrong command bytes\n');
        status = -1;
        return;
    end

    
end

