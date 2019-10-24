EXRToolbox
===========

EXRToolbox is a MATLAB toolbox for importing and exporting multi-band EXR images,
based on the TinyEXR implementation developed by Syoyo Fujita and the
HDRToolbox developed by Francesco Banterle. EXRToolbox does not require installation 
of any EXR libraries and it has been successfuly compiled in Mac OS HighSierra, Mojave, and Catalina.

License: This software is distributed under GPL v3 license (see license.txt)

HOW TO INSTALL and TEST:
=========================
The toolbox does not require installation of any EXR libraries.

1) To install type in Matlab's command window: 
    >> exrMakeAll
This will compile the two mex files that import and export multi-band EXR images

2) To test type in the Matlab's command window: 
    >> testEXR
This will import and visualize a number of test EXR images (located in the 
inputEXRimages directory) and export (in the outpoutEXRimages directory) a 
scrambled version of each input EXR image, in which the central region is flipped vertically.
It will then compare the input and the output EXR images to make sure they match in the
non-scrambled regions.


USAGE OF IMPORT/EXPORT FUNCTIONS:
==================================

% Import an EXR image and, optionally, the channel names.
    >> [exrImage, exrImageChannelNames] = importEXRImage(exrFileName);

% Export and EXR image
    >> exportEXRImage(exrFileName, exrImage, exrImageChannelNames);
% where:
%   exrImage is an [nRows x mCols x kChannels] matrix, and
%   exrImageChannelNames is a cell array of names for each of the kChannels


Nicolas P. Cottaris
October 2019
