% HumanPhotopigmentSSTest.m
%
% Test suite for wrapper function.
%
% 2/6/14    ms      Wrote it.

% Define wavelength spacing.
S = [380 2 201];

ComparePhotopigmentSS('LCone', 'LCone10DegTabulatedSS');
ComparePhotopigmentSS('MCone', 'MCone10DegTabulatedSS');
ComparePhotopigmentSS('SCone', 'SCone10DegTabulatedSS');
ComparePhotopigmentSS('Rods', 'CIE1924VLambda');
ComparePhotopigmentSS('Rods', 'RodsLegacy');
ComparePhotopigmentSS('Melanopsin', 'MelanopsinLegacy');