function appendMessageToFile(obj, message)
    % appendMessageToFile - Appends a message with a timestamp to the specified file.
    %
    % Inputs:
    %    message - Message to append to the file
    %
    % Example:
    %    appendMessageToFile('Your custom message');

    maxRetries = 5;
    retryDelay = 0.1; % seconds
    retryCount = 0;

    while retryCount < maxRetries
        % Open the file for appending
        fileID = fopen(obj.dropbox_filePath, 'a');

        % Check if the file opened successfully
        if fileID == -1
            retryCount = retryCount + 1;
            pause(retryDelay);
        else
            % Get the current timestamp
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');

            % Append the message with a timestamp to the file
            fprintf(fileID, '%s - MATLAB: %s\n', timestamp, message);

            % Close the file
            fclose(fileID);
            return;
        end
    end

    % If we reach here, it means we failed to open the file
    error('Failed to open file for writing after %d retries.', maxRetries);
end