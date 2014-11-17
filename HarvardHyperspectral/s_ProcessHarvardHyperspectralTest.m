% s_ProcessHarvardHyperspectralTest
%
% See if we can figure out a fairly slick way
% to get non-mosaic'd and mosaic'd data out
% of the Harvard database.  Demonstrates
% basic data format.
%
% Depends on Psychtoolbox and SimToolbox.
%
% 7/25/11  dhb, gt  Wrote it.
% 11/18/11 dhb, ncb Move to toolbox, rename, show mono mosaic'd image

%% Clear
clear; close all;

%% Load in the calibrtion data
sensorCalib = load('calib.txt');

%% Load in a hyperspectral image
theRawHyperspectralImage = load('img1');
[nRows,nCols,nWls] = size(theRawHyperspectralImage.ref);

%% Define wavelengths
S = [420 10 31];
wls = SToWls(S);

%% Load in spectral sensitivites that we want to simulate
% Here we'll use our Nikon D70 RGB spectral sensitivites
camCal = LoadCamCal('standard');
T_simulate = SplineCmf(camCal.S_camera,camCal.T_camera,S);
nSensors = size(T_simulate,1);

%% Build up camera image
nonMosaicImage = zeros(nRows,nCols,nSensors);
for i = 1:nSensors
    for j = 1:nWls
        nonMosaicImage(:,:,i) = nonMosaicImage(:,:,i) + T_simulate(i,j)*theRawHyperspectralImage.ref(:,:,j)/sensorCalib(j);
    end
end

%% Look at simulated image
figure; clf;
imshow((nonMosaicImage/max(nonMosaicImage(:))).^0.5);


%% Dummy up a SimToolbox camera whose purpose is to allow us
% to use SimToolbox routines to simulate the mosaicing
camera.manufacturer = 'Dummy';
camera.name =  'Dummy';
camera.numberSensors = nSensors;
camera.wavelengthSampling = S;
camera.spectralSensitivity = T_simulate;
camera.unit = 'None';
camera.lens = 50;
camera.angularResolution.x = 113.4;
camera.angularResolution.y = 113.4;
camera.spatialLayout.dims(1) = 2;
camera.spatialLayout.dims(2) = 2;
camera.spatialLayout.dims(3) = 1;
camera.spatialLayout.mosaic = [3 2 ; 2 1];
camera.comments = 'For Processing Harvard Hyperspectral';

image.imageType = 'sensor';
image.mosaiced = 0;
image.images = nonMosaicImage;
image.cameraFile = camera;
image.exposureTime = 1;
image.height = nRows;
image.width = nCols;
image.comments = 'For Processing Harvard Hyperspectral';

%% Get the mosaic'd sensor responses.  These
% are still in three planes in the simMosaicImage version.
% We can make 1 plane by summing.
simMosaicImage = SimMosaic(image,camera);
mosaicImage = sum(simMosaicImage.images,3);

%% Treat the mosaiced image as grayscale and look at it
figure; clf;
imshow(mosaicImage/max(mosaicImage(:)));

%% Linear interpolation demosaicing
linInterpDemosaicImage = SimFastLinearInterp(simMosaicImage);

%% Look at the stupidly demosaic'd image
figure; clf;
imshow((linInterpDemosaicImage.images/max(linInterpDemosaicImage.images(:))).^0.5);

