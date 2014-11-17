% ProcessRawMatToCalibrated
%
% This takes raw camera data and converts to calibrated formats.
%
% Function parameters:
%   silent -- if 1, does not ask any questions interactively, if 0 it will
%   ask about the path etc.
%   
%   path   -- the path (directory) that will be processed 
%   check  -- if 1, will plot diagnostic information about RGB->LMS
%   conversion
%
% Output
%   imageName_RGB.mat -- Contains RGB_Image.  This is raw camera RGB values, without dark subtraction
%                        or standardization.
%   imageName_LMS.mat -- Contains LMS_Image.  This is isomerization rates estimated from camera responses.
%   imageName_Lum.mat -- Contains LUM_Image.  This is luminance in cd/m2 estimated from camera resopnses.
%
%
% See also
%  ProcessNEFToPGM, ProcessPGMToRawMat
%
% 9/27/05   dhb, pbg      Wrote it by lobotomizing scale_ppm.m
% 01/21/10  dhb, ar       Modified from a previous test program.
% 01/22/10  dhb           Getting better.
% 01/25/10  dhb           Merge with old nef_to_ppm.m file, to process directory.
% 01/28/10  cb, ar        Added a command to call the specified directory
% 01/28/10  cb, ar        Changes pgm to ppm, because dcraw v.571 creates ppm and not pgm 
% 05/18/10  dhb, gt, pg   Update.
% 06/25/10  gt            Changed into a function.
% 07/08/10  gt            Uses LoadCamCal now.
% 08/20/10  gt            Warn on weakly dark pixels (all values < 200) if the fraction is greater than 10%; warn on short exposure durations
% 12/20/10  dhb           Rewrite to use new functions for scale factor and dark subtract, and calibration info for conversions.
% 12/22/10  dhb           Optional dump of RGB jpeg.  Useful for checking
% coordinates of stuff in downsampled images.

function ProcessRawMatToCalibrated(silent, path, check, rgbjpeg)
    if (nargin < 1 || isempty(silent))
        silent = 0;
    end
    if (nargin < 3 || isempty(check))
        check = 0;
    end
    if (nargin < 4 || isempty(rgbjpeg))
        rgbjpeg = 0;
    end

    %% List NEF files of given directory
    if (silent == 0)
        defaultAnswer = pwd;
        thePrompt = sprintf('Enter the name of the NEF image directory [%s]: ',defaultAnswer);
        theDirectory = input(thePrompt,'s'); 
        if (isempty(theDirectory))
            theDirectory = defaultAnswer;
        end
    else
        theDirectory = path;
    end
    fprintf('Image directory is %s\n',theDirectory);
    fileSpec = [theDirectory, filesep, '*.NEF'];
    theFiles = dir(fileSpec);

    %% Loop over all files and process.
    for f = 1:length(theFiles)
        % Get filename parsed
        [nil,filename] = fileparts(theFiles(f).name);
        filename = sprintf('%s/%s', theDirectory, filename);
        fprintf('Processing file %s\n',filename);

        % Get header info directly
        checkImageInfo(f) = GetNEFInfo(filename); %#ok<*SAGROW>
        fprintf('\t\tCamera: %s\n',checkImageInfo(f).whichCamera);
        fprintf('\t\tExposure %g\n',checkImageInfo(f).exposure);
        fprintf('\t\tfStop %g\n',checkImageInfo(f).fStop);
        fprintf('\t\tISO %g\n',checkImageInfo(f).ISO);

        % Load raw file
        load([filename '.raw.mat']);

        % Check that raw mat file header matches
        if (~strcmp(theImage.imageInfo.whichCamera,checkImageInfo(f).whichCamera))
            error('File header mismatch between NEF and raw.mat');
        end
        if (theImage.imageInfo.exposure ~= checkImageInfo(f).exposure)
            error('File header mismatch between NEF and raw.mat');
        end
        if (theImage.imageInfo.fStop ~= checkImageInfo(f).fStop)
            error('File header mismatch between NEF and raw.mat');
        end
        if (theImage.imageInfo.ISO ~= checkImageInfo(f).ISO)
            error('File header mismatch between NEF and raw.mat');
        end
       
        % Get calibration data
        Cam_Cal = LoadCamCal(theImage.imageInfo.whichCamera);

        % Dark subtract and convert to standard exposure, fStop, and ISO 
        RGB_Image = theImage.rawCameraRGB;
        scaleFactor = GetStandardizingCameraScaleFactor(theImage.imageInfo);
        normalizedRGB = scaleFactor*DarkCorrect(Cam_Cal,theImage.imageInfo,RGB_Image);
        [normalizedRGBCalFormat,nX,nY] = ImageToCalFormat(normalizedRGB);
        
        % Write normalized jpeg if desired
        if (rgbjpeg)
            imwrite(RGB_Image/max(RGB_Image(:)),[filename '_RGB.jpg'],'jpg');
        end
        
        % Convert to LMS fundamentals and luminance
        calFormatLMS = Cam_Cal.M_RGBToLMS*normalizedRGBCalFormat;
        imageLMS = CalFormatToImage(calFormatLMS,nX,nY);
        calFormatLum = Cam_Cal.M_LMSToLum*calFormatLMS;
        LUM_Image = CalFormatToImage(calFormatLum,nX,nY);
           
        % Get isomerization rates from LMS
        LMS_Image = imageLMS;
        for k = 1:3
            LMS_Image(:,:,k) = LMS_Image(:,:,k)*Cam_Cal.LMSToIsomerizations(k);
        end
   
        % Write out mat files
        save([filename '_LMS.mat'], 'LMS_Image');
        save([filename '_LUM.mat'], 'LUM_Image');
        save([filename '_RGB.mat'], 'RGB_Image');
        
        clear Image;
        Image.RGB_scale_factor = scaleFactor;
        Image.image_info       = theImage.imageInfo;
        Image.saturated_pixels = 1.0 * sum(sum(sum(RGB_Image >= 16384,3)>=1)) / (size(RGB_Image,1) * size(RGB_Image,2));
        Image.dark_pixels      = 1.0 * sum(sum(sum(RGB_Image <= 10,3)==3)) / (size(RGB_Image,1) * size(RGB_Image,2));
        Image.dark_pixels_200  = 1.0 * sum(sum(sum(RGB_Image <= 200,3)==3)) / (size(RGB_Image,1) * size(RGB_Image,2));

        Image.warning          = '';
        
        if (Image.saturated_pixels > 0.05)
            Image.warning      = [Image.warning ' [Saturated pixel (any of raw RGB equal to 16384) fraction > 0.05]'];
        end
        if (Image.dark_pixels > 0.05)
            Image.warning      = [Image.warning ' [Dark pixel (raw RGB all less than 10) fraction > 0.05]'];
        end
        if (Image.image_info.exposure > 1)
            Image.warning      = [Image.warning ' [Exposure > 1 s; maybe nonlinear regime]'];
        end
        if (Image.image_info.exposure < 4/1000)
            Image.warning      = [Image.warning ' [Exposure < 4/1000 s; maybe nonlinear regime]'];
        end
        if (Image.dark_pixels_200 > 0.1)
            Image.warning      = [Image.warning ' [Weakly dark pixel (raw RGB all less than 200) fraction > 0.1]'];
        end
       
        save([filename '_AUX.mat'], 'Image');
    end

end
