function [sliderValue, gotT] = ReadSlider(port, waitForButtonPress)
% sliderValue = ReadSlider(port, [waitForButtonPress])
%
% Description:
% Reads the current slider value.
%
% Required Input:
% port (integer) - Port number from which to read.
%
% Optional Input:
% waitForButtonPress (boolean) - Indicates if the function should wait
%	until the slider button is pressed before returning.  Defaults to false.
%
% Output:
% sliderValue (integer) - Value representing the current slider position.
%	Returns an empty matrix if no data is available.
% gotT (boolean) - If true, the function registered a button press.

if nargin < 1 || nargin > 2
	error('Usage: sliderValue = ReadSlider(port, [waitForButtonPress])');
end

if nargin == 1
	waitForButtonPress = false;
end

if waitForButtonPress
	while true
		% Read the current slider position.
		sliderValue = slReadT(port, []);

		% Break out of the loop if we got the button press.
		if ~isempty(sliderValue)
			gotT = true;
			break;
		end
	end
else
	[sliderValue, gotT] = slReadRaw(port);
end


function [sliderValue, gotT] = slReadRaw(port)
persistent is64;

is64 = false;
if isempty(is64)
    if strcmp(computer, 'MACI64')
        is64 = true;
    else
        is64 = false;
    end
end

processData = true;
gotT = false;

% Do a read to see if there's any data in the buffer.  If there isn't, just
% return an empty matrix.
if is64
    tmpData = SerialComm('read', port)';
else
    tmpData = IOPort('Read', port);
end
if isempty(tmpData)
	sliderValue = [];
	return;
end

% Read until the buffer is empty.  This insures that we get the latest
% value from the slider.
data = [];
while true
	% If the slider button was pressed during a raw read, handle it.
	xIndex = find(tmpData == 88); %#ok<EFIND>
	if ~isempty(xIndex)
		sliderValue = slReadT(port, tmpData);
		gotT = true;
		processData = false;
		break;
	end
	
	data = [data, tmpData]; %#ok<AGROW>

	if isempty(tmpData) && length(data) > 5
		break;
	end
	
    if is64
        tmpData = SerialComm('read', port)';
    else
        tmpData = IOPort('Read', port);
    end
end

if processData
	% Find all indices that represent blanks.  The value we char about sits
	% between any 2 of these.
	blankIndices = find(data == 13);

	if ~isempty(blankIndices)
		sliderValue = str2double(char(data(blankIndices(end-1)+1:blankIndices(end)-1)));
	else
		sliderValue = [];
	end
end



function sliderValue = slReadT(port, data)
persistent is64;

is64 = false;
if isempty(is64)
    if strcmp(computer, 'MACI64')
        is64 = true;
    else
        is64 = false;
    end
end

sliderValue = [];

if isempty(data)
	% Read the raw slider data.
    if is64
        data = SerialComm('read', port)';
    else
        data = IOPort('Read', port);
    end
end

% Look for an 'X' in the data.  This means the slider button was
% pressed.
xIndex = find(data == 88);
if ~isempty(xIndex)
	% Keep grabbing data until we have a complete value returned.  Some
	% reads will only return half the value.
	if (length(data) - xIndex + 1) < 4
		while true
            if is64
                data = [data, SerialComm('read', port)']; %#ok<AGROW>
            else
                data = [data, IOPort('Read', port)]; %#ok<AGROW>
            end
			if (length(data) - xIndex + 1) >= 4
				break;
			end
		end
	end
	
	% Grab the slider value.
	sliderValue = str2double(char(data(xIndex+2:xIndex+3)));
end

% Keep reading until the buffer is empty.
if is64
    while ~isempty(SerialComm('read', port))
    end
else
    while ~isempty(IOPort('Read', port))
    end
end

