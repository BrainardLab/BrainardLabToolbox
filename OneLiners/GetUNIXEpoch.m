function out = GetUNIXEpoch
% out = GetUNIXEpoch
%
% Gets UNIX Epoch from system. Useful for some applications.
%
% 2/5/14    ms      Wrote it.
[~, out] = system('date +%s');