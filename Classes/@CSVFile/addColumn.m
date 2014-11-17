function CSVObj = addColumn(CSVObj, columnHeader, columnDataType)
% CSVObj = addColumn(columnHeader, columnDataType)
%
% Description:
% Adds a new empty column to the CSVFile object.
%
% Input:
% columnHeader (string) - The column header.
% columnDataType (string) - This value sets how the column data values are
%    written to the .csv file.  This parameter must match the column data
%    format or things won't come out correctly.  'columnDataType' will be a
%    single character that conforms to the formatting types specified by
%    the help documentation of fprintf.
%
% Output:
% CSVObj (CSVFile) - The updated CSVFile object.

persistent formattingTypes;

if isempty(formattingTypes)
	formattingTypes = {'d', 'i', 'ld', 'li', 'u', 'o', 'x', 'X', 'lu', ...
					   'lo', 'lx', 'lX', 'f', 'e', 'E', 'g', 'G', 'bx', 'bX', ...
					   'bo', 'bu', 'tx', 'tX', 'to', 'tu', 'c', 's'};
end

if nargin ~= 3
	error('Usage: CSVObj = addColumn(columnHeader, columnDataType)');
end

if nargout ~= 1
	error('The updated CSVFile object must be stored, e.g. CSVFileObject = addColumn(CSVFileObject, ''columnName'').');
end

if ~ischar(columnHeader)
	error('"columnHeader" must be a string.');
end

if ~ischar(columnDataType) || ~any(strcmp(columnDataType, formattingTypes))
	error('"columnDataType" must be a string that matches one of the formatting strings specified by fprintf.');
end

% Make sure the column hasn't already been added.
if ~isempty(strmatch(columnHeader, CSVObj.ColumnHeaders, 'exact'))
	error('Column "%s" has already been added.', columnHeader);
end

CSVObj.NumColumns = CSVObj.NumColumns + 1;
CSVObj.ColumnHeaders{CSVObj.NumColumns} = columnHeader;
CSVObj.ColumnDataTypes{CSVObj.NumColumns} = sprintf('%%%s', columnDataType);
