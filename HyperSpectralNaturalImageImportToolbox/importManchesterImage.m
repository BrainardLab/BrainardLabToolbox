function importManchesterImage
   
    sourceDir      = getpref('HyperSpectralNaturalImageImportToolbox', 'originalDataBaseDir');
    destinationDir = getpref('HyperSpectralNaturalImageImportToolbox', 'isetbioSceneDataBaseDir');
    
    sceneData = struct(...
        'name', 'scene4', ...
        'referencePaintFileName', 'ref_n7.mat', ...
        'reflectanceDataFileName', 'ref_cyflower1bb_reg1.mat', ...                         % Scene reflectance data
        'spectralRadianceDataFileName', 'radiance_by_reflectance_cyflower1.mat' ...        % Spectral radiance factor to convert scene reflectance to radiances in mWatts/steradian/m^2/nm - akin to the scene illuminant
    );
    
    [referenceSurfaceData, radianceData] = importSceneData(sourceDir, sceneData);
    
end



function [referenceSurfaceData, radianceData] = importSceneData(sourceDir, sceneData)

    % Load the reference surface data
    referenceSurfaceData = referenceSurfaceDataForScene(sourceDir, sceneData);
    
    % Load the scene reflectance data ('reflectances');
    reflectances = [];
    load(fullfile(sourceDir, sceneData.name, sceneData.reflectanceDataFileName));
    if (isempty(reflectances))
        error('Data file does not contain the expected ''reflectances'' field.');
    end
    % Note: The 'reflectances' were computed as the ratio of the recorded radiant spectrum to the recorded radiant spectrum from a neutral matt reference surface embedded in the scene, 
    % multiplied by the known spectral reflectance of the reference surface. Although the reference surface is well illuminated, some portions of the scene hmay have higher radiance, 
    % therefore the reflectances in those regions will exceed 1.   
    
    % Load the reflectanceToRadiance scaling factors ('radiance')
    % Spectral radiance factors required to convert scene reflectance to radiances in mWatts/steradian/m^2/nm
    % This is akin to the scene illuminant
    radiance = [];
    load(fullfile(sourceDir, sceneData.name, sceneData.spectralRadianceDataFileName));
    if (isempty(radiance))
        error('Data file does not contain the expected ''radiance'' field.');
    end
    
    wave = squeeze(radiance(:,1));
    reflectanceToRadianceScaleFactors = squeeze(radiance(:,2));
    % make sure that wave numbers match for ref_n7, radiance
    if (any(abs(wave-referenceSurfaceData.paintMaterial.wave) > 0))
        error('wave numbers for scene radiance and refenence surface  do not match');
    end
    
 
   
    % make sure that wave numbers match (in numerosity) between  'radiance' % and 'reflectances'
    if (size(reflectances,3) ~= size(radiance,1))
       error('spectral samples for scene radiance and reflectances do not match');
    end
   
    % Compute radianceMap from reflectances and reflectanceToRadianceScaleFactors
    radianceMap = bsxfun(@times, reflectances, reshape(reflectanceToRadianceScaleFactors, [1 1 numel(reflectanceToRadianceScaleFactors)]));
    
    % Divide power per nm by spectral bandwidth
    radianceMap = radianceMap / (wave(2)-wave(1));
    
    % Load CIE '32 CMFs
    sensorXYZ = loadXYZCMFs();
    wattsToLumens = 683;
    
    % Compute XYZ image
    sceneXYZimage = MultispectralToSensorImage(radianceMap, WlsToS(wave), sensorXYZ.T, sensorXYZ.S);
    
    % Compute reference luminance
    computedfromRadianceReferenceLuminance = computeROIluminance(referenceSurfaceData, sceneXYZimage);

    % compute radiance scale factor, so that the computed luminance of the
    % reference surface  matches the measured luminance of the reference surface
    radianceScaleFactor = referenceSurfaceData.spectroRadiometerReadings.Yluma/computedfromRadianceReferenceLuminance;
    
    
    % Second pass: adjust scene radiance and
    % reflectanceToRadianceScaleFactors (illuminant)
    radianceMap = radianceMap * radianceScaleFactor;
    reflectanceToRadianceScaleFactors = reflectanceToRadianceScaleFactors * radianceScaleFactor;
    sceneXYZimage = MultispectralToSensorImage(radianceMap, WlsToS(wave), sensorXYZ.T, sensorXYZ.S);
    adjustedRadianceReferenceLuminance = computeROIluminance(referenceSurfaceData, sceneXYZimage);
    fprintf('\nReference luminance (cd/m2):\n\tcomputed: %2.2f\n\treported: %2.2f\n' , adjustedRadianceReferenceLuminance, referenceSurfaceData.spectroRadiometerReadings.Yluma);
    
    
    minSceneLuminance = wattsToLumens*min(min(squeeze(sceneXYZimage(:,:,2))));
    maxSceneLuminance = wattsToLumens*max(max(squeeze(sceneXYZimage(:,:,2))));
    fprintf('\nScene luminance (cd/m2):\n\tMin: %2.2f\n\tMax: %2.2f\n\tRatio:%2.0f\n', minSceneLuminance, maxSceneLuminance, maxSceneLuminance/minSceneLuminance);
    
    % Compute sRGB image
    clipLuminance = 12000;
    gammaValue    = 2.5;
    sRGBimage     = sRGBFromXYZimage(sceneXYZimage, clipLuminance, gammaValue);
    
    % Display sRGBimage with red square
    figure(1); clf;
    imshow(labelReferenceSurface(sRGBimage, referenceSurfaceData), 'Border','tight'); truesize;
   
    % Return data
    radianceData = struct(...
        'wave', wave, ...
        'radianceMap', radianceMap, ...
        'illuminant', reflectanceToRadianceScaleFactors, ...
        'sRGBimage', sRGBimage...
    );

end


function referenceSurfaceData = referenceSurfaceDataForScene(sourceDir, sceneData)

    switch (sceneData.name)
        
        case 'scene4'   
            % Spectral data for reference paint material
            % Load the reference paint spectral data ('ref_n7')
            ref_n7 = [];
            load(fullfile(sourceDir, sceneData.name, sceneData.referencePaintFileName));
            if (isempty(ref_n7))
                error('Data file does not contain the expected ''ref_n7'' field.');
            end
            referenceSurfaceData = struct(...
                'spectroRadiometerReadings', struct( ...
                    'xChroma',      0.351, ...     % 
                    'yChroma',      0.363, ...
                    'Yluma',        8751,  ...     % cd/m2
                    'CCT',          4827   ...     % deg kelvin
                    ), ...
                 'paintMaterial', struct( ...
                    'name',   'Munsell N7 matt grey', ...
                    'wave', ref_n7(:,1),...
                    'spd',  ref_n7(:,2) ...
                 ), ...
                 'geometry', struct( ...
                    'shape',            'sphere', ...
                    'distanceToCamera', 1.4, ...         % meters
                    'diameter',         3.75/100.0, ...  % meters
                    'roiXYpos',         [70 980], ...
                    'roiSize',          [10 10] ...
                 ), ...
                 'info', ['Recorded in the Gualtar campus of University of Minho, Portugal, on 31 July 2002 at 17:40, ' ...
                        'under direct sunlight and blue sky. Ambient temperature: 29 C. ' ...
                        'Camera aperture: f/22, focus: 38, zoom set to maximum giving a focal length of 75 mm'] ...
            );
        
    end  % switch
    

end


function sRGBimage = labelReferenceSurface(originalSRGBimage, referenceSurfaceData)
    sRGBimage = originalSRGBimage;
    cols = referenceSurfaceData.geometry.roiXYpos(1) + (-referenceSurfaceData.geometry.roiSize(1):referenceSurfaceData.geometry.roiSize(1));
    rows = referenceSurfaceData.geometry.roiXYpos(2) + (-referenceSurfaceData.geometry.roiSize(2):referenceSurfaceData.geometry.roiSize(2));
    sRGBimage(rows, cols,1) = 1;
    sRGBimage(rows, cols,2) = 0;
    sRGBimage(rows, cols,3) = 0;
end

function roiLuminance = computeROIluminance(referenceSurfaceData, sceneXYZimage) 
    cols = referenceSurfaceData.geometry.roiXYpos(1) + (-referenceSurfaceData.geometry.roiSize(1):referenceSurfaceData.geometry.roiSize(1));
    rows = referenceSurfaceData.geometry.roiXYpos(2) + (-referenceSurfaceData.geometry.roiSize(2):referenceSurfaceData.geometry.roiSize(2));
    v = sceneXYZimage(rows, cols, 2);
    wattsToLumens = 683;
    roiLuminance = wattsToLumens * mean(v(:));
end


function sRGBimage = sRGBFromXYZimage(sceneXYZimage, clipLuminance, gammaValue)
    [sceneXYZcalFormat, nCols, mRows] = ImageToCalFormat(sceneXYZimage);
    
    % Clip luminance
    scenexyYcalFormat = XYZToxyY(sceneXYZcalFormat);
    wattsToLumens = 683;
    lumaChannel = wattsToLumens * scenexyYcalFormat(3,:);
    lumaChannel(lumaChannel > clipLuminance) = clipLuminance;
    scenexyYcalFormat(3,:) = lumaChannel/wattsToLumens;
    sceneXYZcalFormat = xyYToXYZ(scenexyYcalFormat);
    
    % Compute sRGB image
    [sRGBcalFormat,M] = XYZToSRGBPrimary(sceneXYZcalFormat/max(sceneXYZcalFormat(:)));
    sRGBimage = CalFormatToImage(sRGBcalFormat, nCols, mRows);

    % Report out of gamut pixels
    lessThanZeroPixels = numel(find(sRGBimage(:) < 0));
    greaterThanOnePixels = numel(find(sRGBimage(:) > 1));
    totalPixels = numel(sRGBimage);
    fprintf('\nsRGB image"\n\tRange: [%2.2f .. %2.2f]', min(sRGBimage(:)), max(sRGBimage(:)));
    fprintf('\n\tPixels < 0: %d out of %d (%2.3f%%)', lessThanZeroPixels, totalPixels, lessThanZeroPixels/totalPixels*100.0);
    fprintf('\n\tPixels > 1: %d out of %d (%2.3f%%)\n\n', greaterThanOnePixels, totalPixels, greaterThanOnePixels/totalPixels*100.0);

    % To gamut
    sRGBimage(sRGBimage < 0) = 0;
    sRGBimage(sRGBimage > 1) = 1;
    
    % Apply inverted gamma table
    sRGBimage = sRGBimage .^ (1/gammaValue);   
end


function sensorXYZ = loadXYZCMFs()
    colorMatchingData = load('T_xyz1931.mat');
    sensorXYZ = struct;
    sensorXYZ.S = colorMatchingData.S_xyz1931;
    sensorXYZ.T = colorMatchingData.T_xyz1931;
    clear 'colorMatchingData';
end

