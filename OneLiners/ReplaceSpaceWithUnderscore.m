function outStr = ReplaceSpaceWithUnderscore(inStr)
%  outStr = ReplaceSpaceWithUnderscore(inStr)
% 
% As the function name indicates.
%
% 2/6/11  dhb  Wrote it.

outStr = inStr;
for i = 1:length(inStr)
    if (inStr(i) == ' ')
        outStr(i) = '_';
    end
end