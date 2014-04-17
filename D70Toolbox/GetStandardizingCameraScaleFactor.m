function factor = GetStandardizingCameraScaleFactor(info)
% factor = GetStandardizingCameraScaleFactor(info)
%
% Compute the scale factor required to bring raw RGB into standardized
% (1 sec, f1.8, ISO 1000) units.
%
% This does not compensate for differences between cameras.
%
% 12/14/10  dhb  Wrote it

factor = (1/info.exposure)*(1000/info.ISO)*((info.fStop/1.8)^2);