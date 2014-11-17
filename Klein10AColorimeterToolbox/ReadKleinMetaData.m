function [direction, frequency, duration] = ReadKleinMetaData(filePath);
% [direction, frequency, duration] = ReadKleinMetaData(fileName);
% 
% Reads a metadata file, which contains three lines:
%
% Line 1: Direction
% Line 2: Frequency [Hz]
% Line 3: Duration [s]
%
% 3/1/2014  ms      Wrote it.
FID = fopen(filePath, 'r');

if FID == -1
    error(['ERROR:  File ' filePath ' does not exist']);
else
    % Obtain the data
    direction = fscanf(FID, '%s\n', 1);
    frequency = fscanf(FID, '%g\n', 1);
    duration = fscanf(FID, '%g');
end