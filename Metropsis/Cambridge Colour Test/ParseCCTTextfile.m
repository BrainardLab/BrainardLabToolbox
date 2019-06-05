function [v_prime_w, u_prime_w, azimuthsTable] = ParseCCTTextfile(fName)
% Parses Metropsis text file for Cambridge Colour test 
%
% Syntax:
%    [v_prime_w, u_prime_w, azimuthsTable] = ParseCCTTextfile(fName)
%
%
% Description:
%    The Metropsis system implements the Cambridge Colour Test and outputs
%    data in an idiosyncratic file format.  This routine parses that file
%    to obtain the threshold contour in the u',v' chromaticity plane.
%
% Inputs
%     fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.
%
% Outputs:
%     v_prime_w         - v_prime value of center
%     u_prime_w         - u_prime value of center
%     azimuthsTable     - array of tested azimuth values and the mean
%                         discrimination for each one


% History:
%    05/30/19  dce       Created routine using code provided by ncp 

    % Retrieve v_prime_w, u_prime_w
    [v_prime_w, u_prime_w] = getValuesOfUVprimeW(fName);
    % Retrieve azimuths table
    azimuthsTable = getAzimuthsTable(fName);
end
 
 
function azimuthsTable = getAzimuthsTable(fName)
    
    azimuthsTable = [];
    
    % Lines we are searching for before we start extracting the azimuths table
    targetLine1 = 'Saturation';
    targetLine2 = 'Std';
    
    % Open file
    fid = fopen(fName);
    
    % Scan file one line at a time
    tline = fgetl(fid);
    
    while ischar(tline)
        % check for targetLine1
        if contains(tline, targetLine1)
            % check for targetLine2
            tline = fgetl(fid);
            if (contains(tline, targetLine2))
                keepLooping = true;
                while (keepLooping)
                    % keep reading lines and filling table long as they start with 'azimuth'
                    azimuthTableRowVals = getAzimuthTableRowFromLineString(fgetl(fid));
                    if (isempty(azimuthTableRowVals))
                        % All done
                        keepLooping = false;
                    else
                        % Insert row
                        row = size(azimuthsTable,1)+1;
                        azimuthsTable(row,:) = azimuthTableRowVals;
                    end
                end % while (keepLooping)
            else
                fprintf('Did not detect line: ''%s''.', targetLine2);
            end
        end 
        % Read next line
        tline = fgetl(fid);
    end
    fclose(fid);
    %disp(azimuthsTable);
 
end
 
function vals = getAzimuthTableRowFromLineString(lineString)
    [~, notMatched] = regexp(lineString,'\s+', 'match', 'split');
    % Check that first item is 'azimuth'
    if (strcmp(notMatched{1}, 'azimuth'))
        vals(1) = str2double(notMatched{2});
        vals(2) = str2double(notMatched{3});
        vals(3) = str2double(notMatched{6});
    else
        vals = [];
    end
end
 
 
function [v_prime_w, u_prime_w] = getValuesOfUVprimeW(fName)
    
    % Lines we are searching for before we start extracting the v_prime_w, u_prime_w
    targetLine1 = 'Independent Variables';
    targetLine2 = 'Value';
    
    % Open file
    fid = fopen(fName);
    
    % Scan first line
    tline = fgetl(fid);
    
    % Scan file one line at a time
    while ischar(tline)
        % check for targetLine1
        if contains(tline, targetLine1)
            % Read the targetLine2
            tline = fgetl(fid);
            if (contains(tline, targetLine2))
                % It is, read next 2 lines to get the 'v_prime_w' and 'u_prime_w' values
                v_prime_w = getPropertyValueFromLineString(fgetl(fid), 'v_prime_w'); 
                u_prime_w = getPropertyValueFromLineString(fgetl(fid), 'u_prime_w');
            else
                fprintf('Did not detect line: ''%s''.', targetLine2);
            end
        end
        % Read next line
        tline = fgetl(fid);
    end
    fclose(fid);
 
end
 
function val = getPropertyValueFromLineString(lineString, propertyName)
    splitStr = regexp(lineString,propertyName,'split');
    if (numel(splitStr) < 2)
        error(sprintf('Did not find a value in line: ''%s'' for property named: ''%s''.', lineString, propertyName));
    else
        val = str2double(splitStr{2});
    end
end
 
