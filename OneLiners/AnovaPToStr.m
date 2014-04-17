function s = AnovaPToStr(p)
% s = AnovaPToStr(p)
%
% Convert p value to string for table
%
% 1/9/07  dhb  Wrote it.
% 8.14.13 dhb  Improved help text.

if (isempty(p))
    s = [];
elseif (p >= 0.05)
    s = sprintf('n.s. (%0.2f)',p);
elseif (p >= 0.01)
    s = '< 0.05';
elseif (p >= 0.005)
    s =  '< 0.01';
elseif (p >= 0.001)
    s = '< 0.005';
else
    s = '< 0.001';
end