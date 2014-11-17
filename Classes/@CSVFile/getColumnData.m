function columnData = getColumnData(CSVObj, columnHeader)
% columnData = getColumnData(columnHeader)
%
% Description:
% Gets the column data associated with the column specified by
% 'columnHeader'.
%
% Input:
% columnHeader (string) - The name of the column whose data should be
%    retrieved.
%
% Output:
% columnData (cell array) - A cell array containing the column data.

if nargin ~= 2
	error('Usage: columnData = getColumnData(columnHeader)');
end

if ~ischar(columnHeader)
	error('"columnHeader" must be a string.');
end

% Get the column index associated with the column header.
columnIndex = CSVObj.findColumnIndex(columnHeader);

columnData = CSVObj.ColumnData{columnIndex};
