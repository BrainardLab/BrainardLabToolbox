% Example script to demonstrate usage of the LJU6dev
%
% 6/5/17  npc    Wrote it.

function demoLJU6
    
    % Set toolbox
    % tbUse('BrainardLabBase');

    % Instantiate a LJU6dev
    U6 = LJU6dev();
    
    % Open the device
    U6.open();
   
    % Recoding loop
    keepGoing = true;
    while (keepGoing)
        % Ask use for recording duration
        durationSeconds = input('Recording duration in seconds: [0 to exit]: ');
        if (durationSeconds > 0)
            % Get the data
            [data, timeAxis] = U6.record(durationSeconds);
            
            % Plot the data
            plotData(data, timeAxis);
        else
            keepGoing = false;
        end
    end %  while (keepGoing)
    
    % Close the device
    U6.close();
end

function plotData(data, timeAxis)
    
    maxVoltage = max(data, [], 1);
    minVoltage = min(data, [], 1);
    hFig = figure(1); clf;
    set(hFig, 'Position', [10 10 850 1000]);
    for channel = 1:size(data,2)
        range = [minVoltage(channel) maxVoltage(channel)];
        if (range(2)-range(1) < 1)
            range = (range(1)+range(2))/2 + [-0.5 0.5];
        end
        subplot(5,1,channel);
        plot(timeAxis, squeeze(data(:,channel)), 'r-', 'LineWidth', 1.5);
        if (channel == 5)
            xlabel('time (seconds)', 'FontWeight', 'bold');
        end
        ylabel('voltage (Volts)', 'FontWeight', 'bold');
        box on; grid on;
        set(gca, 'Color', [1 1 1], 'FontSize', 14, 'XLim', [timeAxis(1) timeAxis(end)], 'YLim', range);
        title(sprintf('AIN %d', channel-1));
    end
end

