function columnHeaders = getColumnHeaders(CSVObj)
% columnHeaders = getColumnHeaders
%
% Description:
% Gets a list of all column headers attached to the CSVFile object.
%
% Output:
% columnHeaders (1xN cell) - A cell array of strings where each string is a
%    column header.  Empty if there are no columns.

if nargin ~= 1
	error('Usage: columnHeaders = getColumnHeaders(CSVObj)');
end

if CSVObj.NumColumns > 0
	columnHeaders = CSVObj.ColumnHeaders;
else
	columnHeaders = [];
end
