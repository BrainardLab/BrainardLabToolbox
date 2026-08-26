function isLastWord = checkLastWordInFile(obj, word)
% checkLastWordInFile  Return true if `word` is the last word on the last line
% of the shared Dropbox log file.
%
% - In a 2-computer setup, the other machine may have the file open for writing,
%   so fopen() can intermittently fail (returns -1).
% - We retry for a short window instead of immediately throwing an error.
% - We use onCleanup() to guarantee fclose() even if an error happens.

    % ----------------------------
    % 0) Basic input validation
    % ----------------------------
    if isempty(obj.dropbox_filePath)
        error('dropbox_filePath is empty.');
    end

    % ----------------------------
    % 1) Try to open the file (with retry)
    % ----------------------------
    % In shared-file workflows, fopen can fail temporarily due to:
    % - file being held open by the other computer (exclusive lock),
    % - Dropbox syncing/renaming the file briefly,
    % - network filesystem latency.
    %
    % Retry for a short duration to ride out these transient conditions.
    fileID = -1;
    t0 = tic;
    maxWaitSec = 600;     % total time to keep retrying
    retryPause = 1;    % pause between retries (seconds)

    while (fileID == -1) && (toc(t0) < maxWaitSec)
        if exist(obj.dropbox_filePath, 'file') ~= 2
            pause(retryPause);
            continue;
        end
        fileID = fopen(obj.dropbox_filePath, 'r');
        if fileID == -1
            pause(0.05);
        end
    end

    % If we still cannot open the file after retrying, throw a helpful error
    if fileID == -1
        error('Failed to open file for reading after %.1f s:\n%s', ...
            maxWaitSec, obj.dropbox_filePath);
    end
    
    cleanupObj = onCleanup(@() fclose(fileID));

    % ----------------------------
    % 2) Read to the end and keep the last non-empty line
    % ----------------------------
    % We read line-by-line so we can reliably capture the last line even for
    % large files without loading everything into memory.
    lastLine = '';

    while ~feof(fileID)
        currentLine = fgetl(fileID);

        % fgetl returns:
        % - a character vector for a normal line
        % - -1 at end-of-file
        if ischar(currentLine)
            % Keep updating lastLine so that when we reach EOF,
            % lastLine is the final line in the file
            lastLine = currentLine;
        end
    end

    % ----------------------------
    % 3) Parse last word and compare
    % ----------------------------
    % Remove leading/trailing whitespace
    lastLine = strtrim(lastLine);

    % If the file is empty or last line is blank, we cannot match
    if isempty(lastLine)
        isLastWord = false;
        return;
    end

    % Split by whitespace (default behavior splits on any whitespace)
    words = strsplit(lastLine);

    % Defensive: if split returns empty for some reason, treat as no match
    if isempty(words)
        isLastWord = false;
        return;
    end

    % Extract the final token and compare to the requested word
    lastWord = words{end};
    isLastWord = strcmp(lastWord, word);

    % ----------------------------
    % Note:
    % - We do NOT pause inside this function.
    % - The caller (polling loop) should handle pacing with pause(0.05–0.2).
    % ----------------------------
end
