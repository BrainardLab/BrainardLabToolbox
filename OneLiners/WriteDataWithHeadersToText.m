function WriteDataWithHeadersToText(fileName,data,headers,precision)
%  WriteDataWithHeadersToText(fileName,data,[headers],[precision])
% 
% Write numerical data to a tab delimited text file, with
% a header row.
%
% Data are a Matlab matrix.  Headers are a cell array of
% headers, with same length as number of columns in data.
% This may be the empty string, in which case no headers
% are written.
%
% Precision is passed to the underlying call to dlmwrite.
%
% 7/7/13  dhb  Wrote it.

% Default args
if (nargin < 3)
    headers = [];
end
if (nargin < 4 || isempty(precision))
    precision = '%g';
end

if (~isempty(headers))
    if (size(data,2) ~= length(headers))
        error('Number of headers does not match column size of data');
    end
end

% First write the headers
if (~isempty(headers))
    fid = fopen(fileName,'wt');
    if (fid == -1)
        error('Error opening file');
    end
    
    
    for i = 1:length(headers)
        fprintf(fid,'%s',headers{i});
        if (i ~= length(headers))
            fprintf(fid,'\t');
        else
            fprintf(fid,'\n');
        end
    end
    fclose(fid);
end

% Then append the data
if (~isempty(headers))
    dlmwrite(fileName,data,'delimiter','\t','-append','precision',precision);
else
    dlmwrite(fileName,data,'delimiter','\t','precision',precision);
end
