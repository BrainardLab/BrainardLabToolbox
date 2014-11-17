% HumanPhotopigmentSSTest.m
%
% Test suite for wrapper function.
%
% 2/6/14    ms      Wrote it.

%% Close and clear
clear; close all;

%% Make sure we are running in the directory that holds this function
[ourDir] = fileparts(mfilename('fullpath'));
cd(ourDir);

%% Define wavelength spacing.
S = [380 2 201];

%% Run a set of useful comparisons
ComparePhotopigmentSS('LCone', 'LCone10DegTabulatedSS');
ComparePhotopigmentSS('MCone', 'MCone10DegTabulatedSS');
ComparePhotopigmentSS('SCone', 'SCone10DegTabulatedSS');
ComparePhotopigmentSS('Rods', 'CIE1924VLambda');
ComparePhotopigmentSS('Rods', 'RodsLegacy');
ComparePhotopigmentSS('Melanopsin', 'MelanopsinLegacy');