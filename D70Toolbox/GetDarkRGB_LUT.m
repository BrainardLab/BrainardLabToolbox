function RGBDark = GetDarkRGB_LUT(time,table)
% RGBDark = GetDarkRGB_LUT(time,table)
%
% Return appropriate RGB values to use in dark subtraction,
% given exposure time and a passed table of measurements.
%
% This is just like GetDarkRGB2, except there's no switch, it just uses the
% look up table
%
% 8/23/05   pbg        Wrote it
% 05/18/10  dhb, pbg, gt  Hard code subtraction based on low light level ISO 400 data.


tableTol = 0.000001;

if (time <= 1.0)
    RGBDark = [0 8 4];
else
    index = find(abs(time - table(:,1)) < tableTol);
    if (length(index) == 1)
        RGBDark = table(index,2:4);
    elseif (length(index) > 1)
        error('Tolerance too high, multiple matches');
    else
        error('No matching exposure duration in dark table');
    end
end