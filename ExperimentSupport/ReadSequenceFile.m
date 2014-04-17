function sequence = ReadSequenceFile(fileName)
% Opens the sequence file specified by 'fileName' and returns the sequence
% as a row vector.

if nargin ~= 1
    error('*** Usage: sequence = ReadSequenceFile(fileName)');
end

% Make sure that we can find the sequence file.
fullFilePath = which(fileName);
if isempty(fullFilePath)
    error('*** Could not find the sequence file: %s', fileName);
end

sequence = textread(fullFilePath, '%d')';