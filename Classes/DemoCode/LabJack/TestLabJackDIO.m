function TestLabJackDIO
% Demo code illustrating functionality of the LabJackDIO class
%
% July 24, 2013   npc    Wrote it
%

    % Clear environment
    clear all; clear global; clear Classes; clc;
    
    % Initialize LabJackDIO object
    ljOBJ = LabJackDIO();
    if (~ljOBJ.deviceIsConfigured)
        disp('A LabJack device was not configured. Exiting now ...');
        return;
    end
    
    % Configure all 16 ditigal channels as OUTPUT
    configureAllChannelsAsOutput(ljOBJ);  
    if (~ljOBJ.DIOconfigurationIsGood)
        disp('>>>> DIO configuration failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    % Test1: Set all channels to 1
    status = setAllChannels(ljOBJ, 1);
    if (status ~= 0)
        disp('>>>> setAllChannels failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    % Test2: Set all channels to 0
    WaitSecs(0.1);
    status = setAllChannels(ljOBJ, 0);
    if (status ~= 0)
        disp('>>>> setAllChannels failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    % Test3: Back to 1
    WaitSecs(0.1);
    status = setAllChannels(ljOBJ, 1);
    if (status ~= 0)
        disp('>>>> setAllChannels failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    % Test4: Back to 0
    WaitSecs(0.1);
    status = setAllChannels(ljOBJ, 0);
    if (status ~= 0)
        disp('>>>> setAllChannels failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    
    % Test 5: Toggle channel FIO_0 only
    WaitSecs(0.1);
    channelID = LabJackDIO.FIO_0;
    disp('Toggling channel FIO_0 to 1');
    
    for k = 1:10
        channelState = 1;
        status = ljOBJ.setLines(channelID, channelState);
    
        channelState = 0;
        status = ljOBJ.setLines(channelID, channelState);
    end
    
    % Test 6: Toggle channels FIO_0 and FIO_1, 1000 times
    WaitSecs(0.5);
    disp('Toggling channels FIO_0 and FIO_1');
    Ntimes = 1000;
    times = zeros(1,Ntimes);
    for k = 1:Ntimes
        tic
        status = ljOBJ.setLines([LabJackDIO.FIO_0 LabJackDIO.FIO_1], [0 1]);
        times(k) = toc*1000;
        status = ljOBJ.setLines([LabJackDIO.FIO_0 LabJackDIO.FIO_1], [0 0]);
        status = ljOBJ.setLines([LabJackDIO.FIO_0 LabJackDIO.FIO_1], [1 0]);
        status = ljOBJ.setLines([LabJackDIO.FIO_0 LabJackDIO.FIO_1], [1 1]);
    end
   
    % Compute some stats
    [mindt, index_of_min] = min(times);
    [maxdt, index_of_max] = max(times);
    [maxdt2, index_of_max2] = max(times(2:end));
    
    fprintf('min dt: %2.4f msecs (%d entry)\n',mindt, index_of_min);
    fprintf('max dt: %2.4f msecs (%d entry)\n', maxdt, index_of_max);
    fprintf('max(2:end) dt: %2.4f msecs (%d entry)\n', maxdt2, index_of_max2);
    fprintf('mean dt: %2.4f msecs\n', mean(times));
    
    
    % Finish up. Set all channels to 0
    status = setAllChannels(ljOBJ, 0);
    if (status ~= 0)
        disp('>>>> setAllChannels failed. Exiting now.');
        ljOBJ.closeDevice();
    end
    
    % Close device and exit
    ljOBJ.closeDevice();
    disp('Ciao');
end


    
function status = setAllChannels(ljOBJ, value)

    allChannelIDs = [...
        LabJackDIO.FIO_0, ...
        LabJackDIO.FIO_1, ...
        LabJackDIO.FIO_2, ...
        LabJackDIO.FIO_3, ...
        LabJackDIO.FIO_4, ...
        LabJackDIO.FIO_5, ...
        LabJackDIO.FIO_6, ...
        LabJackDIO.FIO_7, ...
        LabJackDIO.EIO_0, ...
        LabJackDIO.EIO_1, ...
        LabJackDIO.EIO_2, ...
        LabJackDIO.EIO_3, ...
        LabJackDIO.EIO_4, ...
        LabJackDIO.EIO_5, ...
        LabJackDIO.EIO_6, ...
        LabJackDIO.EIO_7];
    if (value == 0)
        bitStates = zeros(1, length(allChannelIDs));
    else
        bitStates = ones(1, length(allChannelIDs)); 
    end
    status = ljOBJ.setLines(allChannelIDs, bitStates);
end


function configureAllChannelsAsOutput(ljOBJ)

    ljOBJ.configureDIOchannels(...
        LabJackDIO.FIO_0, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_1, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_2, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_3, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_4, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_5, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_6, LabJackDIO.OUTPUT, ...
        LabJackDIO.FIO_7, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_0, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_1, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_2, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_3, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_4, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_5, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_6, LabJackDIO.OUTPUT, ...
        LabJackDIO.EIO_7, LabJackDIO.OUTPUT);
end
