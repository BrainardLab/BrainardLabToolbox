function image = MakeNikonSimImage(imageData)
% image = MakeNikonSimImage(imageData)
%
% Take a MATLAB matrix that represents the image
% data from one of our Nikon cameras and put it
% into a format appropriate for using SimToolbox routines.
%
% 11/4/04   dhb, jmk       Wrote it.
% 9/27/05   dhb, pbg       Mask data for each plane with mosaic.

% Define camera and read it.
camera.manufacturer = 'Nikon';
camera.name =  'D70';
camera.numberSensors = 3;
camera.wavelengthSampling = [400 10 31];
camera.spectralSensitivity = zeros(1,camera.wavelengthSampling(3));
camera.unit = 'None';
camera.lens = 50;
camera.angularResolution.x = 113.4;
camera.angularResolution.y = 113.4;
camera.spatialLayout.dims(1) = 2;
camera.spatialLayout.dims(2) = 2;
camera.spatialLayout.dims(3) = 1;
camera.spatialLayout.mosaic = [3 2 ; 2 1];
%camera.spatialLayout.mosaic = [2 1 ; 3 2];
camera.comments = 'Nikon D70';

% Read in one picMat matrix
[height,width] = size(imageData);
camera.height = height;
camera.width = width;

% Create the mosaic data.
mosaicMask = SimCreateMask(camera,height,width); 
image.imageType = 'sensor';
image.mosaiced = 1;
image.images = zeros(camera.height,camera.width,camera.numberSensors);
for i = 1:camera.numberSensors
    image.images(:,:,i) = imageData .* mosaicMask(:,:,i);
end

image.cameraFile = camera;
image.exposureTime = 1;
image.height = height;
image.width = width;
image.comments = 'Created by NikonSimImage';
