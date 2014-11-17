function status = setDIOword(decimalValue)

    global LABJACKstruct

    
    status = 0;
    
    if (~LABJACKstruct.devicePointerIsValid)
        disp('LABJACK device pointer is not valid. ConfigDevice will not execute');
        status = -1;
        return;
    end
    
    if ((decimalValue < 0) | (decimalValue > 65535))
        disp('* * * decimalValue is setDIOword must be between 0 and 65535. Fatal Error !! * * *');
        status = -1;
        return;
    end
    
    
    global Stimulator

  
    
    % First, send the Word Separator
    binaryVector = dec2bin(Stimulator.Bionics.Constants.WordSeparator, 16);    % Create a 16-bit word to represent the word separator
    bitStates    = uint8(binaryVector)-uint8('0');                           % valid options are:  0 = LOW    1 = HIGH 
    status       = setDigitalLines(LABJACKstruct.DIO16bitChannelArrangement, bitStates);

    if (status ~= 0)
        disp('failed to set 16-bit digital lines');
        return;
    end
    
    
    % Second, send the desired uint16 value
    binaryVector = dec2bin(decimalValue,16);                                % Create a 16-bit word to represent the decimal Value                     
    bitStates    = uint8(binaryVector)-uint8('0');                          % valid options are:  0 = LOW    1 = HIGH 
    status       = setDigitalLines(LABJACKstruct.DIO16bitChannelArrangement, bitStates);
    
    if (status ~= 0)
        disp('failed to set 16-bit digital lines');
        return;
    end
        
end




function status = setDigitalLines(channelIDs, bitStates)

    global Stimulator
    
    % wait some time
    WaitSecs(Stimulator.Bionics.Constants.WriteDelayInSeconds);
    
   
    
    sendDataMessage             = zeros(2*length(channelIDs),1, 'uint8');
    
    indices                     = 1+2*[0:length(channelIDs)-1];
    
    sendDataMessage(indices)    = 11;              % IOType is BitStateWrite
    sendDataMessage(indices+1)  = channelIDs + 128*bitStates;
    
    
    
    status = sendLowLevelCommand(sendDataMessage);
     
    
end
 
