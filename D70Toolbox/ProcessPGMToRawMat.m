% ProcessPGMToRawMat(silent, imageDir, displayRaw)
%
% This takes the PGM images produced by ProcessNEFToPGM and puts them into
% standard MATLAB format.  Desmoaics by block averaging.  Does not dark
% subtract.
%
% Parameters: silent -- if 1, noninteractive, if 0, interactive mode;
%             displayRaw -- plots the extracted image
%
% See also
%  ProcessNEFToPGM, ProcessRawMatToCalibrated
%
% 9/27/05   dhb, pbg      Wrote it by lobotomizing scale_ppm.m
% 01/21/10  dhb, ar       Modified from a previous test program.
% 01/22/10  dhb           Getting better.
% 01/25/10  dhb           Merge with old nef_to_ppm.m file, to process directory.
% 01/28/10  cb, ar        Added a command to call the specified directory
% 01/28/10  cb, ar        Changes pgm to ppm, because dcraw v.571 creates ppm and not pgm 
% 05/18/10  dhb, gt       Split out raw processing from color conversion.  Add in ISO normalization.
%                         Use imageDecimateFast, not blockproc.
% 06/25/10  gt            Changed into a function
% 11/10/10  dhb           Remove computation of scale factor and demosaicImageScaled, because these were not used.
%           dhb           Change variable name "path" to "imageDir" to avoid name collision with path function
% 7/5/11    dhb           Handle displayRaw not passed.


function ProcessPGMToRawMat(silent, imageDir, displayRaw)
    if (nargin == 0 || isempty(silent)) silent = 0; end;
    
    if (nargin < 3 || isempty(displayRaw)) displayRaw = 0;

    %% List NEF files of given directory
    if (silent == 0)
        defaultAnswer = pwd;
        thePrompt = sprintf('Enter the name of the NEF image directory [%s]: ',defaultAnswer);
        theDirectory = input(thePrompt,'s'); 
        if (isempty(theDirectory))
            theDirectory = defaultAnswer;
        end
    else
        theDirectory = imageDir;
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

        % Get image information
        imageInfo(f) = GetNEFInfo(filename); %#ok<*SAGROW>
        fprintf('\t\tCamera: %s\n',imageInfo(f).whichCamera);
        fprintf('\t\tExposure %g\n',imageInfo(f).exposure);
        fprintf('\t\tfStop %g\n',imageInfo(f).fStop);
        fprintf('\t\tISO %g\n',imageInfo(f).ISO);

        mosaicPGMName = [filename '.ppm'];
        mosaicMonoImage = double(imread(mosaicPGMName));
        mosaicMonoImage = mosaicMonoImage(1:2014,1:3038);
        if (displayRaw)
            figure; imshow(mosaicMonoImage/max(mosaicMonoImage(:)));
            drawnow;
        end

        % Set up mosaic mask and produce a three channel image where
        % each channel is masked according to the sensor mosaic.
        simImage = MakeNikonSimImage(mosaicMonoImage);
        mosaicMask = SimCreateMask(simImage.cameraFile,simImage.height,simImage.width);
        rawDemosaicImage = zeros(size(mosaicMask));
        for k = 1:3
            rawDemosaicImage(:,:,k) = mosaicMonoImage .* mosaicMask(:,:,k);
            fprintf('\tMaximum raw for channel %d, %g\n',k,max(max(rawDemosaicImage(:,:,k))));
        end

        % Block average the image.  This is pretty slow for a full image.
        demosaicImage = zeros(2014/2,3038/2,3);
        demosaicImage(:,:,1) = 4*imageDecimateFast(rawDemosaicImage(:,:,1)); %(blockproc(rawDemosaicImage(:,:,1),[2 2],@blkmean2);
        demosaicImage(:,:,2) = 2*imageDecimateFast(rawDemosaicImage(:,:,2)); %blockproc(rawDemosaicImage(:,:,2),[2 2],@blkmean2);
        demosaicImage(:,:,3) = 4*imageDecimateFast(rawDemosaicImage(:,:,3)); %blockproc(rawDemosaicImage(:,:,3),[2 2],@blkmean2);
        for k = 1:3
            fprintf('\tMaximum blk average for channel %d, %g\n',k,max(max(demosaicImage(:,:,k))));
        end

        % Save the MATLAB version of the raw image.  If you want to bring it into normalized format, 
        % multiply the raw image by the scale factor.
        theImage.imageInfo = imageInfo(f);
        theImage.rawMosaic = mosaicMonoImage;
        theImage.rawCameraRGB = demosaicImage;
        save([filename '.raw.mat'],'theImage');
    end

end

