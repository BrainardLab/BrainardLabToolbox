% CSVFile
%
% Description:
% The CSVFile class represents a .csv file that can be read into Excel or
% any other spreadsheet application, and allows for basic functionality
% such as reading, writing, and modifying a .csv file's contents.
classdef CSVFile
	properties (SetAccess = private)
		FileName;
		ColumnHeaders;
		NumColumns = 0;
		ColumnData;
		ColumnDataTypes;
		ColumnLengths;
	end
	
	methods
		% Constructor
		function CSVObj = CSVFile(fileName, overWrite)
			if nargin < 1 || nargin > 2
				error('Usage: CSVObj = CSVFile(fileName, [overWrite])');
			end
			
			if nargin == 1
				overWrite = false;
			end
			
			% Verify the input.
			if ~ischar(fileName)
				error('fileName must be a string.');
			end
			
			% If we aren't in overwrite mode, open and read the file if it
			% exists.
			if ~overWrite && exist(fileName, 'file')
				% Read the raw file contents.
				fid = fopen(fileName, 'r');
				if fid == -1
					error('Cannot open file "%s".', fileName);
				end
				t = textscan(fid, '%s', 'Delimiter', '\n');
				rawText = t{1};
				
				% We get the column headers from the first line.
				ch = textscan(rawText{1}, '%s', 'Delimiter', ',');
				CSVObj.ColumnHeaders = ch{1};
				CSVObj.NumColumns = length(CSVObj.ColumnHeaders);
				
				% Now load in the rest of the column data.
				frewind(fid);
				CSVObj.ColumnData = textscan(fid, repmat('%s', 1, CSVObj.NumColumns), ...
					'Delimiter', ',', 'HeaderLines', 1);
				
				% Close the file.
				fclose(fid);
			end
			
			CSVObj.FileName = fileName;
		end
		
		% Public Functions
		CSVObj = addColumn(CSVObj, columnHeader, columnDataType)
		columnHeaders = getColumnHeaders(CSVObj)
		CSVObj = setColumnData(CSVObj, columnHeader, columnData)
		columnData = getColumnData(CSVObj, columnHeader)
		write(CSVObj)
	end
	
	% Private functions
	methods (Access = private)
		columnIndex = findColumnIndex(CSVObj, columnHeader)
	end
end
