% Example script to demonstrate usage of the LJU6dev
%
% 6/5/17  npc    Wrote it.

function demoLJU6
    
    % Set toolbox
    % tbUse('BrainardLabBase');

    % Specify list of channel ids to record from.
    % You can select any combination of these channels: AIN0, AIN1, AIN2, AIN3, AIN4
    % e.g.: channelsToRecordFrom = {'AIN0', 'AIN1', 'AIN2', 'AIN3', 'AIN4'};
    channelsToRecordFrom = {'AIN0', 'AIN1'};
    
    % Specify sampling frequency. Currently only 1 KHz is allowed
    samplingFrequencyKHz = 1.0; 
    
    % Instantiate a LJU6dev to handle communication with the LabJack U6
    U6 = LJU6dev(...
        'inputChannels', channelsToRecordFrom, ...
        'samplingFrequencyKHz', samplingFrequencyKHz ...            
    );
    
    % Open the device
    U6.open();
   
    % Recoding loop
    keepGoing = true;
    while (keepGoing)
        % Prompt the user to enter a recording duration
        durationSeconds = input('Recording duration in seconds: [0 to exit]: ');
        if (durationSeconds > 0)
            % Trigger data acquisition. Program halts here until all data are collected
            [data, timeAxis, channelLabels] = U6.record(durationSeconds);
            
            % Plot the data
            plotData(data, timeAxis, channelLabels);
        else
            keepGoing = false;
        end
    end %  while (keepGoing)
    
    % Close the device
    U6.close();
end

function plotData(data, timeAxis, channelLabels)
    
    maxVoltage = max(data, [], 1);
    minVoltage = min(data, [], 1);
    recordedChannelsNum = size(data,2);
    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 850 40+200*recordedChannelsNum]);
    for channel = 1:recordedChannelsNum
        range = [minVoltage(channel) maxVoltage(channel)];
        if (range(2)-range(1) < 1)
            range = (range(1)+range(2))/2 + [-0.5 0.5];
        end
        subplot(recordedChannelsNum,1,channel);
        plot(timeAxis, squeeze(data(:,channel)), 'r-', 'LineWidth', 1.5);
        if (channel == recordedChannelsNum)
            xlabel('time (seconds)', 'FontWeight', 'bold');
        end
        ylabel('voltage (Volts)', 'FontWeight', 'bold');
        box on; grid on;
        set(gca, 'Color', [1 1 1], 'FontSize', 14, 'XLim', [timeAxis(1) timeAxis(end)], 'YLim', range);
        title(channelLabels{channel});
    end
end

