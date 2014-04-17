function [data,headers] = ReadDataWithHeadersFromText(fileName)
%  ReadDataWithHeadersFromText(fileName)
% 
% Read numerical data to a tab delimited text file, with
% a header row.
%
% Data are a Matlab matrix.  Headers are a cell array of
% headers, with same length as number of columns in data.
% This may be the empty string, in which case no headers
% were there.
%
% 7/7/13  dhb  Wrote it.

theRawRead = importdata(fileName,'\t');
if (isstruct(theRawRead))
    data = theRawRead.data;
    headers = theRawRead.colheaders;
else
    data = theRawRead;
    headers = [];
end

if (~isempty(headers))
    if (size(data,2) ~= length(headers))
        error('Length of headers does not match column size of data');
    end
end