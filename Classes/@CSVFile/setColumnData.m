function CSVObj = setColumnData(CSVObj, columnHeader, columnData)
% CSVObj = setColumnData(columnID, columnData)
%
% Description:
% Sets the data associated with a particular column.
%
% Input:
% columnHeader (string) - The column to modify.
% columnData (cell array | numerical matrix) - Can be a cell array for
%	something like a list of strings or a numerical matrix.  In the case of
%	numerical matrices, each row of the matrix is written out as a single
%	value in the .csv file.
%
% Output:
% CSVObj (CSVFile) - Updated CSVFile object.

if nargin ~= 3
	error('Usage: CSVObj = setColumnData(columnID, columnData)');
end

if nargout ~= 1
	error('The updated CSVFile object must be stored.');
end

if ~ischar(columnHeader)
	error('"columnHeader" must be a string.');
end

% Make sure the columnData input is of a valid format.
if iscell(columnData) && isvector(columnData)
	% Valid
elseif isnumeric(columnData) && ndims(columnData) == 2
	% Valid
else
	error('"columnData" must be a cell array or numerical matrix.');
end

if CSVObj.NumColumns < 1
	error('No columns exist to add data to.');
end

% Get the column index associated with 'columnHeader'.
columnIndex = CSVObj.findColumnIndex(columnHeader);

% Set the column data.
CSVObj.ColumnData{columnIndex} = columnData;

% Record the number of rows, i.e. length for cells and the M dimension for
% matrices, in the column data.
if iscell(columnData)
	CSVObj.ColumnLengths(columnIndex) = length(columnData);
else
	CSVObj.ColumnLengths(columnIndex) = size(columnData, 1);
end
