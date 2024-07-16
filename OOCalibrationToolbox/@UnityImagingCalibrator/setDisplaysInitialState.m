function setDisplaysInitialState(obj)

    % Open the file for writing
    fileID = fopen(obj.dropbox_filePath, 'w');
    
    % Check if the file opened successfully
    if fileID == -1
        error('Failed to open file for writing.');
    else
        % Get the current timestamp
        timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    
        % Write text to the file
        fprintf(fileID, '%s - MATLAB: Initialize_Unity\n', timestamp);
    
        % Close the file
        fclose(fileID);
    end
    
    % Check if Unity has sent back a message indicating that initialization is done
    while true
        % Read the last word in the file and check if it is "Finished_Screen_Setup"
        isUnityInitialized = checkLastWordInFile(obj.dropbox_filePath, "Finished_Screen_Setup");
        if isUnityInitialized
            break;
        end
    end
    
end