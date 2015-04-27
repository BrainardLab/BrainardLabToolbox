function importManchesterImage
   
    sourceDir      = getpref('HyperSpectralNaturalImageImportToolbox', 'originalDataBaseDir');
    destinationDir = getpref('HyperSpectralNaturalImageImportToolbox', 'isetbioSceneDataBaseDir');
    
    sceneData = struct(...
        'name', 'scene4', ...
        'referencePaintFileName', 'ref_n7.mat', ...
        'reflectanceDataFileName', 'ref_cyflower1bb_reg1.mat', ...                         % Scene reflectance data
        'spectralRadianceDataFileName', 'radiance_by_reflectance_cyflower1.mat' ...        % Spectral radiance factor to convert scene reflectance to radiances in Watts/steradian/m^2/nm - akin to the scene illuminant
    );
    
    [radianceData, referenceObjectData] = importSceneData(sourceDir, sceneData);
    
    % Generate isetbio scene
    scene = sceneFromHyperSpectralImageData(...
        'sceneName',            radianceData.sceneName, ...
        'wave',                 radianceData.wave, ...
        'illuminantEnergy',     radianceData.illuminant, ... 
        'radianceEnergy',       radianceData.radianceMap, ...
        'sceneDistance',        referenceObjectData.geometry.distanceToCamera, ...
        'scenePixelsPerMeter',  referenceObjectData.geometry.sizeInMeters / referenceObjectData.geometry.sizeInPixels ...
    );
    
    exportFileName = exportScene(scene, destinationDir);
    clear 'scene';
    
    load(exportFileName);
    % display scene
    vcAddAndSelectObject(scene); sceneWindow;
    
    % human optics
    oi = oiCreate('human');
    
    % Compute optical image of scene and
    oi = oiCompute(scene,oi);
    
    % Shown optical image
    vcAddAndSelectObject(oi); oiWindow;

end

function exportFileName = exportScene(scene, destinationDir)
    exportFileName = fullfile(destinationDir, sceneGet(scene, 'name'));
    save(exportFileName, 'scene');
    fprintf('Scene ''%s'' saved to ''%s''', sceneGet(scene, 'name'), exportFileName);
end


function scene =  sceneFromHyperSpectralImageData(varargin)

    % Set all expected input arguments to empty
    sceneName      = '';
    wave           = [];
    illuminantEnergy = [];
    radianceEnergy = [];
    sceneDistance  = [];
    scenePixelsPerMeter = [];
    % Generate parse object to parse the input arguments
    parser = inputParser;
    parser.addParamValue('sceneName',           sceneName,              @ischar);
    parser.addParamValue('wave',                wave,                   @isvector);
    parser.addParamValue('illuminantEnergy',    illuminantEnergy,       @isvector);
    parser.addParamValue('radianceEnergy',      radianceEnergy,         @(x) (ndims(x)==3));
    parser.addParamValue('sceneDistance',       sceneDistance,          @isnumeric);
    parser.addParamValue('scenePixelsPerMeter', scenePixelsPerMeter,    @isnumeric);
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       p.(pNames{k}) = parser.Results.(pNames{k});
       if (isempty(p.(pNames{k})))
           error('Required input argument ''%s'' was not passed', p.(pNames{k}));
       end
    end
    
    % Create scene object
    scene = sceneCreate('multispectral');
    
    % Set the name
    scene = sceneSet(scene,'name', p.sceneName);   
    
    % Set the spectal sampling
    scene = sceneSet(scene,'wave', p.wave);
    
    % Generate isetbio illuminant struct for the scene
    sceneIlluminant = illuminantCreate('d65', p.wave);
    sceneIlluminant = illuminantSet(sceneIlluminant,'name', sprintf('%s-illuminant', p.sceneName));
    sceneIlluminant = illuminantSet(sceneIlluminant,'photons', Energy2Quanta(p.wave, p.illuminantEnergy));
    % Set the scene's illuminant
    scene = sceneSet(scene,'illuminant',sceneIlluminant);
    
    % Set the scene radiance (in photons/steradian/m^2/nm)
    scene = sceneSet(scene,'photons', Energy2Quanta(p.wave, p.radianceEnergy));
    
    % Illuminant scaling must be done after photons are set. The
    % multispectral data all have an illuminant structure that is set, so
    % they do not pass through this step.
    scene = sceneIlluminantScale(scene);
    
    meanSceneLuminanceFromIsetbio = sceneGet(scene, 'mean luminance');
    fprintf('ISETBIO''s estimate of mean scene luminance: %2.2f cd/m2\n', meanSceneLuminanceFromIsetbio);
    
    % Set the scene distance
    scene = sceneSet(scene, 'distance', p.sceneDistance);
    
    % Set the angular width (in degrees)
    sceneWidthInMeters  = size(p.radianceEnergy,2) * p.scenePixelsPerMeter;
    sceneWidthInDegrees = 2.0 * atan( 0.5*sceneWidthInMeters / p.sceneDistance)/pi * 180; 
    scene = sceneSet(scene, 'wAngular', sceneWidthInDegrees);
end


function [radianceData, referenceObjectData] = importSceneData(sourceDir, sceneData)

    % Load the reference surface data
    referenceObjectData = referenceObjectDataForScene(sourceDir, sceneData);
    
    % Load the scene reflectance data ('reflectances');
    reflectances = [];
    load(fullfile(sourceDir, sceneData.name, sceneData.reflectanceDataFileName));
    if (isempty(reflectances))
        error('Data file does not contain the expected ''reflectances'' field.');
    end
    
    % Note: The 'reflectances' were computed as the ratio of the recorded radiant spectrum to the recorded radiant spectrum from a neutral matt reference surface embedded in the scene, 
    % multiplied by the known spectral reflectance of the reference surface. Although the reference surface is well illuminated, some portions of the scene may have higher radiance, 
    % therefore the reflectances in those regions will exceed 1.   
    
    % Load the reflectanceToRadiance scaling factors ('radiance')
    % Spectral radiance factors required to convert scene reflectance to radiances in Watts/steradian/m^2/nm
    % This is akin to the scene illuminant in some arbitrary units
    radiance = [];
    load(fullfile(sourceDir, sceneData.name, sceneData.spectralRadianceDataFileName));
    if (isempty(radiance))
        error('Data file does not contain the expected ''radiance'' field.');
    end
    
    wave = squeeze(radiance(:,1));
    illuminant = squeeze(radiance(:,2));
    figure(1);
    plot(wave, illuminant, 'ks-');
    
    % make sure that wave numbers match for ref_n7, radiance
    if (any(abs(wave-referenceObjectData.paintMaterial.wave) > 0))
        error('wave numbers for scene radiance and refenence surface  do not match');
    end
    
 
    % make sure that wave numbers match (in numerosity) between  'radiance' % and 'reflectances'
    if (size(reflectances,3) ~= size(radiance,1))
       error('spectral samples for scene radiance and reflectances do not match');
    end
   
    % Compute radianceMap from reflectances and illuminant
    radianceMap = bsxfun(@times, reflectances, reshape(illuminant, [1 1 numel(illuminant)]));
    
    % Divide power per nm by spectral bandwidth
    radianceMap = radianceMap / (wave(2)-wave(1));
    
    % Load CIE '32 CMFs
    sensorXYZ = loadXYZCMFs();
    wattsToLumens = 683;
    
    
    adjustRadianceToMatchReportedAndComputedRefLuminances = false;
    if (adjustRadianceToMatchReportedAndComputedRefLuminances ) 
        % Compute XYZ image
        sceneXYZimage = MultispectralToSensorImage(radianceMap, WlsToS(wave), sensorXYZ.T, sensorXYZ.S);
    
        % Compute reference luminance
        computedfromRadianceReferenceLuminance = computeROIluminance(referenceObjectData, sceneXYZimage);
    
        % compute radiance scale factor, so that the computed luminance of the
        % reference surface  matches the measured luminance of the reference surface
        radianceScaleFactor = referenceObjectData.spectroRadiometerReadings.Yluma/computedfromRadianceReferenceLuminance
    
        % Second pass: adjust scene radiance and illuminant
        radianceMap  = radianceMap * radianceScaleFactor;
        illuminant   = illuminant * radianceScaleFactor;
    end
    
    % Compute XYZ image
    sceneXYZimage      = MultispectralToSensorImage(radianceMap, WlsToS(wave), sensorXYZ.T, sensorXYZ.S);
    % Compute scene luminance range and mean
    minSceneLuminance  = wattsToLumens*min(min(squeeze(sceneXYZimage(:,:,2))));
    maxSceneLuminance  = wattsToLumens*max(max(squeeze(sceneXYZimage(:,:,2))));
    meanSceneLuminance = wattsToLumens*mean(mean(squeeze(sceneXYZimage(:,:,2))));
    % Compute reference luminance
    computedfromRadianceReferenceLuminance = computeROIluminance(referenceObjectData, sceneXYZimage);
    
    fprintf('\nReference luminance (cd/m2):\n\tcomputed: %2.2f\n\treported: %2.2f\n' , computedfromRadianceReferenceLuminance, referenceObjectData.spectroRadiometerReadings.Yluma);
    fprintf('\nScene radiances (Watts/steradian/m2/nm):\n\tMin: %2.2f\n\tMax: %2.2f\n', min(radianceMap(:)), max(radianceMap(:)));
    fprintf('\nScene luminance (cd/m2):\n\tMin  : %2.2f\n\tMax  : %2.2f\n\tMean : %2.2f\n\tRatio: %2.0f:1\n', minSceneLuminance, maxSceneLuminance, meanSceneLuminance, maxSceneLuminance/minSceneLuminance);
    
    % Compute sRGB image
    clipLuminance = 12000;
    gammaValue    = 2.5;
    sRGBimage     = sRGBFromXYZimage(sceneXYZimage, clipLuminance, gammaValue);
    
    % Display sRGBimage with red square
    figure(2); clf;
    imshow(labelReferenceSurface(sRGBimage, referenceObjectData), 'Border','tight'); truesize;
   
    % Return data
    radianceData = struct(...
        'sceneName', sceneData.name, ...
        'wave', wave, ...
        'radianceMap', radianceMap, ...                         
        'illuminant', illuminant, ...                           
        'sRGBimage', sRGBimage...
    );

end


function referenceObjectData = referenceObjectDataForScene(sourceDir, sceneData)

    switch (sceneData.name)
        
        case 'scene4'   
            % Spectral data for reference paint material
            % Load the reference paint spectral data ('ref_n7')
            ref_n7 = [];
            load(fullfile(sourceDir, sceneData.name, sceneData.referencePaintFileName));
            if (isempty(ref_n7))
                error('Data file does not contain the expected ''ref_n7'' field.');
            end
            referenceObjectData = struct(...
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
                    'sizeInMeters',     3.75/100.0, ...  % for this scene, the reported size is the ball diameter
                    'sizeInPixels',     167, ...         % estimated manually from the picture
                    'roiXYpos',         [83 981], ...    % pixels
                    'roiSize',          [10 10] ...      % pixels
                 ), ...
                 'info', ['Recorded in the Gualtar campus of University of Minho, Portugal, on 31 July 2002 at 17:40, ' ...
                        'under direct sunlight and blue sky. Ambient temperature: 29 C. ' ...
                        'Camera aperture: f/22, focus: 38, zoom set to maximum giving a focal length of 75 mm'] ...
            );
        
    end  % switch
    


end


function sRGBimage = labelReferenceSurface(originalSRGBimage, referenceObjectData)
    sRGBimage = originalSRGBimage;
    cols = referenceObjectData.geometry.roiXYpos(1) + (-referenceObjectData.geometry.roiSize(1):referenceObjectData.geometry.roiSize(1));
    rows = referenceObjectData.geometry.roiXYpos(2) + (-referenceObjectData.geometry.roiSize(2):referenceObjectData.geometry.roiSize(2));
    sRGBimage(rows, cols,1) = 1;
    sRGBimage(rows, cols,2) = 0;
    sRGBimage(rows, cols,3) = 0;
end

function roiLuminance = computeROIluminance(referenceObjectData, sceneXYZimage) 
    cols = referenceObjectData.geometry.roiXYpos(1) + (-referenceObjectData.geometry.roiSize(1):referenceObjectData.geometry.roiSize(1));
    rows = referenceObjectData.geometry.roiXYpos(2) + (-referenceObjectData.geometry.roiSize(2):referenceObjectData.geometry.roiSize(2));
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
    fprintf('\nsRGB image\n\tRange: [%2.2f .. %2.2f]', min(sRGBimage(:)), max(sRGBimage(:)));
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

