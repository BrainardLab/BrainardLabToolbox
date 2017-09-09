function [wls, spectralRadiance] = GetLabSphereCalibratedSpectralRadiance
%[wls, spectralRadiance] = GetLabSphereCalibratedSpectralRadiance
%
% Returns the tabulated spectral radiance in mW/cd2-sr-um for the Brainard
% Lab LabSphere USC-SR calibrated light source. The values below are from
% the calibration certificate (#89597-1-1, 6/10/2015).
%
% 6/16/15   ms      Tabulated from document.

wls = [300 310 320 330 340 350 400 450 500 555 600 655 700 800 900 1050 1150 1200 1300]'; % nm
spectralRadiance = [7.70e-4 8.92e-4 9.39e-4 8.68e-4 1.11e-3 1.37e-3 6.13e-1 2.17e0 4.57e0 7.49e0 9.3e0 1.15e1 9.49e0 4.96e-1 2.09e-1 1.31e0 9.42e-1 1.9e0 1.23e0]'; % mW/cm2-sr-um
