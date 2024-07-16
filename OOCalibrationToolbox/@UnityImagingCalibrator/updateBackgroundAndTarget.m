function updateBackgroundAndTarget(obj, targetSettings)
    
    % Create a message indicating the current stimulus to display
    message_imageForDisplay = sprintf("R%.4f_G%.4f_B%.4f Image_Display",...
        targetSettings(1), targetSettings(2), targetSettings(3));
    
    % Append the message to the file
    obj.appendMessageToFile(obj.dropbox_filePath, message_imageForDisplay);

    % Set a timeout duration (in seconds)
    timeout = 30; % seconds
    startTime = tic;

    % Wait for Unity to send back a message indicating that the image has been displayed
    while true
        if obj.checkLastWordInFile(obj.dropbox_filePath, "Image_Successfully_Displayed")
            break;
        end

        % Check if the timeout duration has been exceeded
        if toc(startTime) > timeout
            error('Timeout: Unity did not confirm image display in time.');
        end

        % Pause for a short period to prevent CPU overload
        pause(0.1); 
    end
end
