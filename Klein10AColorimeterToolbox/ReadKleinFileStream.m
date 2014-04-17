function [t, s, s_demeaned, frequency, range, date] = ReadKleinFileStream(filePath);
% [t, s] = ReadKleinFileStream(filePath);
%
% Reads an 'uncorrected' Klein files produced by K10Ascope.m and returns
% the content.
%
% 3/1/2014  ms  Wrote it.

% Open the file
FID = fopen(filePath, 'r');
if FID == -1
    error(['ERROR:  File ' filePath ' does not exist']);
else
    % Obtain the data
    date = fscanf(FID,'%s %s', [1 2]);
    
    % Obtain the sensitivity range
    range = fscanf(FID,'%s\n', [1 1]);
    
    % Process the columns
    Acolumns = fscanf(FID,'%d', [1 1]);
    columnHeaders = fscanf(FID,'%s', [1 3]);
    A = fscanf(FID,'%g', [2 Acolumns]);
    Bcolumns = fscanf(FID,'%d', [1 1]);
    columnHeaders = fscanf(FID,'%s', [1 4]);
    B = fscanf(FID,'%g', [4 Bcolumns]);
    
    % Pull out what we want
    s = A(2, :);
    s_demeaned = s-mean(A(2, :));
    t = A(1, :);
    
    % Get the mean sampling frequency.
    frequency = round(1/mean(diff(t)));
end