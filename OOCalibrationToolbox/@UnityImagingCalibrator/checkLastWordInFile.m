function isLastWord = checkLastWordInFile(obj, word)
    % checkLastWordInFile - Checks if the specified word is the last word
    % of the last line in the given file.
    %
    % Syntax: isLastWord = checkLastWordInFile(filePath, word)
    %
    % Inputs:
    %    filePath - Path to the file to be checked
    %    word - Word to check for as the last word of the last line
    %
    % Outputs:
    %    isLastWord - Returns true if the word is the last word of the
    %    last line, otherwise false

    % Open the file for reading
    fileID = fopen(obj.dropbox_filePath, 'r');

    % Check if the file opened successfully
    if fileID == -1
        error('Failed to open file for reading.');
    else
        % Initialize variable to store the last line
        lastLine = '';
        
        % Read the file line by line until the end
        while ~feof(fileID)
            currentLine = fgetl(fileID);
            if ischar(currentLine)
                lastLine = currentLine;
            end
        end
        
        % Close the file
        fclose(fileID);
        
        % Trim whitespace from the last line
        lastLine = strtrim(lastLine);
        
        % Split the last line into words
        words = strsplit(lastLine, ' ');
        
        % Get the last word
        lastWord = words{end};
        
        % Check if the last word matches the specified word
        isLastWord = strcmp(lastWord, word);
    end
end
