function str = countToStr(count, unit, varargin)
% Converts a count of units to a human readable character array
%
% Syntax:
%   str = countToStr(count, unit)
%
% Description:
%    Converts an count of units to human readable string, in character
%    array form. If count is non-zero, character array will indicate 'X
%    [unit]', and append the plural 's' when appropriate. If count is 0,
%    str will be empty (default, can be overridden using kwarg 'dropZero').
%
% Inputs:
%    count - numeric, indicating how many [units] to use
%    unit  - string/character array, specifying which string to use as the
%            singular unit
%
% Outputs:
%    str   - character array, in the form 'X [unit(s)]'
%
% Optional key/value pairs:
%    'format'   - formatstring, specifying how to format the count. See
%                 sprintf. Default = '%.2f'.
%    'dropZero' - logical, return empty string when count is 0. If false,
%                 will str will read '0 [unit(s)]' when count = 0. Default
%                 true.
% 
% Examples provided in source code.
%
% See also:
%    sprintf

% History:
%    05/11/18  jv  wrote it.

% Examples:
%{
    %% '15 cows'
    str = countToStr(15,'cow');
%}
%{
    %% '0.00 seconds'
    str = countToStr(0, 'second','dropZero',false);
%}
%{
    %% '0 seconds'
    str = countToStr(0, 'second','dropZero',false,'format','%d');
%}


%% Input validation
parser = inputParser;
parser.addRequired('count',@isnumeric);
parser.addRequired('unit',@ischar);
parser.addParameter('format','%.2f',@ischar);
parser.addParameter('dropZero',true,@islogical);
parser.parse(count, unit, varargin{:});

%% Convert
if parser.Results.dropZero && count == 0
    str = '';
else
    if count == 0 || count > 1
        s ='s';
    else
        s = '';
    end
    str = sprintf([parser.Results.format ' %s%s'], count, unit, s);
end
end