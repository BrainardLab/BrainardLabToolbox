function object = setParamValue(object, paramName, value)
% Sets the value of 'paramName'.

if nargin ~= 3
	error('Usage: object = setParamValue(paramName, value)');
end

fi = NaN;

% Find the specified parameter.
for i = 1:length(object.Params)
	if strcmp(paramName, object.Params(i).paramName)
		fi = i;
		break;
	end
end

if isnan(fi)
	error('Could not find parameter %s', paramName);
end

% Convert 'value' into the appropriate format.
switch object.Params(fi).paramType
	case 'd'
		if isnumeric(value)
			% do nothing
		elseif ischar(value)
			[value, ok] = str2num(value); %#ok<ST2NM>
			
			if ~ok
				error('Failed to convert %s to double value', value);
			end
		else
			error('Cannot convert value to double');
		end
		
		rawVal = num2str(value);
		
	case 's'
		if ischar(value)
			% do nothing
		elseif ~ischar(value)
			value = num2str(value);
		end
		
		rawVal = value;
		
	case 'b'
		if islogical(value)
			% do nothing
		elseif ischar(value)
			if any(strcmp(value, {'true', '1'}))
				value = true;
			elseif any(strcmp(value, {'false', '0'}))
				value = false;
			else
				error('Invalid boolean value %s', value);
			end
		elseif isnumeric(value) && isscalar(value)
			value = logical(value);
			
		else
			error('Cannot convert value to logical');
		end
		
		rawVal = num2str(value);
end

object.Params(fi).paramValRaw = rawVal;
object.Params(fi).paramVal = value;

% Remake the raw text line for this parameter.
obp = object.Params(fi);
if isempty(obp.paramDescription)
	textLine = sprintf('%s:%s:%s', obp.paramName, obp.paramType, obp.paramValRaw);
else
	textLine = sprintf('%s:%s:%s:%s', obp.paramName, obp.paramType, ...
		obp.paramValRaw, obp.paramDescription);
end
object.RawText(obp.textIndex) = {textLine};
	
