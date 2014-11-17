function cal = SplineCal(cal,S)
% cal = SplineCal(cal,S)
%
% Resample the spectral functions in a calibration file.
% This can be used in certain circumstances to make
% calculations go faster by reducing precision of
% the wavelength sampling.
%
% This resamples the key data structures, not the raw data.
%
% 9/11/10  dhb  Wrote it.

%% Device
cal.P_device = SplineSpd(cal.S_device,cal.P_device,S);
eyeDevice = eye(cal.S_device(3),cal.S_device(3));
if (max(abs(cal.T_device-eyeDevice)) ~= 0)
    error('Don''t know what to do when T_device is not identity matrix');
else
    cal.T_device = eye(S(3),S(3));
end
cal.S_device = S;

%% Ambient
cal.P_ambient = SplineSpd(cal.S_ambient,cal.P_ambient,S);
eyeAmbient = eye(cal.S_ambient(3),cal.S_ambient(3));
if (max(abs(cal.T_ambient-eyeAmbient)) ~= 0)
    error('Don''t know what to do when T_ambient is not identity matrix');
else
    cal.T_ambient = eye(S(3),S(3));
end
cal.S_ambient = S;

