function columnIndex = findColumnIndex(CSVObj, columnHeader)
% columnIndex = findColumnIndex(columnHeader)
%
% Description:
% Finds the numerical column index given a column header name.  Throws an
% error if the column isn't found.
%
% Input:
% columnHeader (string) - The column header.
%
% Output:
% columnIndex (integer) - The index into the object properties that contain
%    data connected to the column specified by 'columnHeader'.

if nargin ~= 2
	error('Usage: columnIndex = findColumnIndex(columnHeader)');
end

if ~ischar(columnHeader)
	error('"columnHeader" must be a string.');
end

% Make sure that the column header specified actually exists.
columnIndex = strmatch(columnHeader, CSVObj.ColumnHeaders, 'exact');
if isempty(columnIndex)
	error('Cannot find column with header "%s".', columnHeader);
end
