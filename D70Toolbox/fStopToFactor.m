function fFactor = fStopToFactor(fStop,conversionChart)
% factor = fStopToFactor(fStop,conversionChart)
%
% Return the normalization factor for the passed fStop, found
% by looking it up in the passed structure array.
%
% 10/29/04  dhb     Wrote it.

for i = 1:length(conversionChart)
    if (fStop == conversionChart(i).fnum)
        fFactor = conversionChart(i).scale
        return;
    end
end

% Handle case where there is no matching fstop.
error('No matching fStop in conversionChart');

