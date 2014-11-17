function write(CSVObj)
% write
%
% Description:
% Writes the data in the CSVFile object and writes it to disk.

if nargin ~= 1
	error('Usage: write(CSVObj) or CSVObj.write');
end

% Make sure we have data to write.
if CSVObj.NumColumns < 1 || isempty(CSVObj.ColumnData)
	error('No data to write.');
end

% Open the file.
fid = fopen(CSVObj.FileName, 'w');
if fid == -1
	error('Could not open "%s".', CSVObj.FileName);
end

% Write out the column headers.
for i = 1:CSVObj.NumColumns
	if i > 1
		fprintf(fid, ',');
	end
	fprintf(fid, CSVObj.ColumnHeaders{i});
end
fprintf(fid, '\n');

% Figure out the longest column length.  We'll iterate over that value and
% stick in empty values for any column whose range we surpass.
maxColumnLength = max(CSVObj.ColumnLengths);
for rowIndex = 1:maxColumnLength
	for columnIndex = 1:CSVObj.NumColumns
		if columnIndex > 1
			fprintf(fid, ',');
		end
		
		% If we've surpassed the number of rows of the column, set its
		% output value for this row to be empty.
		if rowIndex > CSVObj.ColumnLengths(columnIndex)
			outputValue = [];
		else
			% If the column data was specified as a cell array we must pull
			% the output value out with squiggly brackets.
			if iscell(CSVObj.ColumnData{columnIndex})
				outputValue = CSVObj.ColumnData{columnIndex}{rowIndex};
			else
				outputValue = CSVObj.ColumnData{columnIndex}(rowIndex,:);
			end
		end
		
		% Write the output value to the file.
		if ischar(outputValue)
			fprintf(fid, CSVObj.ColumnDataTypes{columnIndex}, outputValue);
		else
			% Numerical values may be scalars or vectors.  In the case of
			% vectors, we stick a space in between each element.
			for outputIndex = 1:length(outputValue)
				if outputIndex > 1
					fprintf(fid, ' ');
				end
				
				fprintf(fid, CSVObj.ColumnDataTypes{columnIndex}, outputValue(outputIndex));
			end
		end
	end
	
	% Stick in a newline before we go to the next row.
	fprintf(fid, '\n');
end

% Close the file now that we're done writing to it.
fclose(fid);
