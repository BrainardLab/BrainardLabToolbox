function Phosphors = SpectroCALMakePhosphorStructure
% Phosphors = SpectroCALMakePhosphorStructure
% 
% This function will concatenate the Red.mat, Blue.mat and Green.mat files
% together and plot the SPD
%
% Once this has been done, type: save Phosphors at the MATLAB command
% prompt to create a MAT file called Phosphors.mat. This is the input file
% required by the CRS Colour Toolbox for MATLAB. To visualise the date run
% GUI_ColourToolbox and click the Load_File ... button to load the
% Phosphors.mat file

load Red
Phosphors.wavelength = Lambda';
Phosphors.Red = Radiance';
load Green
Phosphors.Green = Radiance';
load Blue
Phosphors.Blue = Radiance';
hold on
plot(Phosphors.wavelength, Phosphors.Red, 'r')
plot(Phosphors.wavelength, Phosphors.Green, 'g')
plot(Phosphors.wavelength, Phosphors.Blue, 'b')