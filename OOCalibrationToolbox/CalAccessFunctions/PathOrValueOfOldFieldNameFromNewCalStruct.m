function [fieldNameFullPath, fieldValue] = PathOrValueOfOldFieldNameFromNewCalStruct(calStruct, oldStyleCalFieldName)
% Function that returns the path (in the new style calStruct) of the field 
% that corresponds to oldStyleCalFieldName (old calStruct momenclature)
% In cases where the fieldValue has different dimensions than that in the
% old style calStruct, the fieldValue is returned with the correct
% dimensions instead of the fieldPath.
% 
% 4/29/2014   npc   Wrote it.
%
%
    fieldNameFullPath  = [];
    fieldValue = [];
    
%   ------------------ cal.describe ---------------------
    if strcmp(oldStyleCalFieldName, 'nPrimaryBases')
        fieldNameFullPath = 'describe.primaryBasesNum';
        
    elseif strcmp(oldStyleCalFieldName, 'nDevices')
        fieldNameFullPath = 'describe.displayPrimariesNum';
        
    elseif strcmp(oldStyleCalFieldName, 'computer')
        fieldNameFullPath = 'describe.computerInfo';
        
    elseif strcmp(oldStyleCalFieldName, 'monitor')
        fieldNameFullPath = 'describe.displayDeviceName';
        
    elseif strcmp(oldStyleCalFieldName, 'driver')
        fieldNameFullPath = 'describe.driver';
        
    elseif strcmp(oldStyleCalFieldName, 'dacsize')
        fieldNameFullPath = 'describe.dacsize';
        
    elseif strcmp(oldStyleCalFieldName, 'hz')
        fieldNameFullPath = 'describe.hz';
    
    elseif strcmp(oldStyleCalFieldName, 'who')
        fieldNameFullPath = 'describe.who';
    
    elseif strcmp(oldStyleCalFieldName, 'date')
        fieldNameFullPath = 'describe.date';
        
    elseif strcmp(oldStyleCalFieldName, 'program')
        fieldNameFullPath = 'describe.executiveScriptName';
    
    elseif strcmp(oldStyleCalFieldName, 'comment')
        fieldNameFullPath = 'describe.comment';
        
    elseif strcmp(oldStyleCalFieldName, 'nDevices')
        fieldNameFullPath = 'describe.displayPrimariesNum';
           
    elseif strcmp(oldStyleCalFieldName, 'fitType')
        fieldNameFullPath = 'describe.gamma.fitType';
        
    elseif strcmp(oldStyleCalFieldName, 'exponents')
        fieldNameFullPath = 'describe.gamma.exponents';
     
    elseif strcmp(oldStyleCalFieldName, 'bgColor')
        fieldNameFullPath = 'describe.bgColor';
    
    elseif strcmp(oldStyleCalFieldName, 'fgColor')
        fieldNameFullPath = 'describe.fgColor';
        
    elseif strcmp(oldStyleCalFieldName, 'usebitspp')
        fieldNameFullPath = 'describe.useBitsPP';
        
    elseif strcmp(oldStyleCalFieldName, 'calibrationType')
        fieldNameFullPath = 'describe.displayDeviceType';
    
    elseif strcmp(oldStyleCalFieldName, 'whichScreen')
        fieldNameFullPath = 'describe.whichScreen';
        
    elseif strcmp(oldStyleCalFieldName, 'blankOtherScreen')
        fieldNameFullPath = 'describe.blankOtherScreen';
    
    elseif strcmp(oldStyleCalFieldName, 'whichBlankScreen')
        fieldNameFullPath = 'describe.whichBlankScreen';
        
    elseif strcmp(oldStyleCalFieldName, 'blankSettings')
        fieldNameFullPath = 'describe.blankSettings';
        
    elseif strcmp(oldStyleCalFieldName, 'meterDistance')
        fieldNameFullPath = 'describe.meterDistance';
        
    elseif strcmp(oldStyleCalFieldName, 'monitor')
        fieldNameFullPath = 'describe.displayDeviceName';
        
    elseif strcmp(oldStyleCalFieldName, 'comment')
        fieldNameFullPath = 'describe.comment';
        
    elseif strcmp(oldStyleCalFieldName, 'gamma')
        fieldNameFullPath = 'describe.gamma';
        
    elseif strcmp(oldStyleCalFieldName, 'leaveRoomTime')
        fieldNameFullPath = 'describe.leaveRoomTime';
        
    elseif strcmp(oldStyleCalFieldName, 'nAverage')
        fieldNameFullPath = 'describe.nAverage';
    
    elseif strcmp(oldStyleCalFieldName, 'nMeas')
        fieldNameFullPath = 'describe.nMeas';
    
    elseif strcmp(oldStyleCalFieldName, 'boxSize')
        fieldNameFullPath = 'describe.boxSize';
        
    elseif strcmp(oldStyleCalFieldName, 'boxOffsetX')
        fieldNameFullPath = 'describe.boxOffsetX';
        
    elseif strcmp(oldStyleCalFieldName, 'boxOffsetY')
        fieldNameFullPath = 'describe.boxOffsetY';
    
    elseif strcmp(oldStyleCalFieldName, 'HDRProjector')
         fieldValue = 0;
         
    elseif strcmp(oldStyleCalFieldName, 'promptforname')
         fieldValue = 1;
         
    elseif strcmp(oldStyleCalFieldName, 'whichMeterType')
        meterType = 0;
        if (strcmp(calStruct.describe.meterModel, 'PR-650'))
            meterType = 1;
        elseif (strcmp(calStruct.describe.meterModel, 'PR-655'))
            meterType = 4;
        elseif (strcmp(calStruct.describe.meterModel, 'PR-670'))
            meterType = 5;    
        end  
        fieldValue = meterType;
         
    elseif strcmp(oldStyleCalFieldName, 'dacsize')
        fieldNameFullPath = 'describe.dacsize';
        
    elseif strcmp(oldStyleCalFieldName, 'svnInfo')
        fieldValue = struct;
        fieldValue.svnInfo    = calStruct.describe.svnInfo;
        fieldValue.matlabInfo = calStruct.describe.matlabInfo;
        
    elseif strcmp(oldStyleCalFieldName, 'caltype')
        fieldNameFullPath = 'describe.displayDeviceType';
        
    elseif strcmp(oldStyleCalFieldName, 'screenSizePixel')
        fieldNameFullPath = 'describe.screenSizePixel';
        
    elseif strcmp(oldStyleCalFieldName, 'displayDescription')
        fieldNameFullPath = 'describe.displaysDescription';
        
    elseif strcmp(oldStyleCalFieldName, 'graphicsEngine')
        fieldNameFullPath = 'describe.graphicsEngine';
     
    elseif strcmp(oldStyleCalFieldName, 'calStructRevisionNo')
        fieldNameFullPath = 'describe.calStructRevisionNo';
        
        
    % ------------------ cal.rawData ---------------------------
    
    elseif strcmp(oldStyleCalFieldName, 'S')
        fieldNameFullPath = 'rawData.S';
        
    elseif strcmp(oldStyleCalFieldName, 'rawGammaInput')
        fieldValue = calStruct.rawData.gammaInput';   
        
    elseif strcmp(oldStyleCalFieldName, 'rawGammaTable')
        fieldNameFullPath = 'rawData.gammaTable';
        
    elseif strcmp(oldStyleCalFieldName, 'monSpd')
        trialsNum           = size(calStruct.rawData.gammaCurveMeasurements,1);
        primariesNum        = size(calStruct.rawData.gammaCurveMeasurements,2); 
        gammaSamples        = size(calStruct.rawData.gammaCurveMeasurements,3); 
        spectralSamples     = size(calStruct.rawData.gammaCurveMeasurements,4);
        
        for trialIndex = 1:trialsNum 
            for primaryIndex = 1:primariesNum   
                tmp = zeros(spectralSamples*gammaSamples,1);
                for gammaPointIndex = 1:gammaSamples
                    firstSample = (gammaPointIndex-1)*spectralSamples + 1;
                    lastSample  = gammaPointIndex*spectralSamples;
                    tmp(firstSample:lastSample) = ...
                        reshape(calStruct.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, gammaPointIndex, :), ...
                        [1 spectralSamples]);
                end  
                fieldValue{trialIndex, primaryIndex} = tmp;
            end
        end
      
     elseif strcmp(oldStyleCalFieldName, 'mon')
        primariesNum        = size(calStruct.rawData.gammaCurveMeasurements,2); 
        gammaSamples        = size(calStruct.rawData.gammaCurveMeasurements,3); 
        spectralSamples     = size(calStruct.rawData.gammaCurveMeasurements,4);
        fieldValue          = zeros(spectralSamples*gammaSamples, primariesNum);
        
        for primaryIndex = 1:primariesNum
        for gammaPointIndex = 1:gammaSamples
            firstSample = (gammaPointIndex-1)*spectralSamples + 1;
            lastSample  = gammaPointIndex*spectralSamples;
            fieldValue(firstSample:lastSample, primaryIndex) = ...
                reshape(squeeze(calStruct.rawData.gammaCurveMeanMeasurements(primaryIndex,gammaPointIndex,:)), ...
                [spectralSamples 1]);
        end
        end
    
    elseif strcmp(oldStyleCalFieldName, 'monIndex')
        trialsNum           = size(calStruct.rawData.gammaCurveMeasurements,1);
        primariesNum        = size(calStruct.rawData.gammaCurveMeasurements,2); 
        gammaSamples        = size(calStruct.rawData.gammaCurveMeasurements,3); 
        spectralSamples     = size(calStruct.rawData.gammaCurveMeasurements,4);
        
        for trialIndex = 1:trialsNum 
            for primaryIndex = 1:primariesNum   
                tmp = zeros(spectralSamples*gammaSamples,1);
                for gammaPointIndex = 1:gammaSamples
                    firstSample = (gammaPointIndex-1)*spectralSamples + 1;
                    lastSample  = gammaPointIndex*spectralSamples;
                    tmp(firstSample:lastSample) = ...
                        reshape(calStruct.rawData.gammaCurveMeasurements(trialIndex, primaryIndex, gammaPointIndex, :), ...
                        [1 spectralSamples]);
                end
                fieldValue{trialIndex, primaryIndex} = reshape(calStruct.rawData.gammaCurveSortIndices(trialIndex, primaryIndex,:), [gammaSamples 1]);  
            end
        end
        
    % ------------ cal.bgmeas struct (in old format) --------------------
      
    elseif (strcmp(oldStyleCalFieldName, 'bgmeas.bgSettings'))
        fieldValue          = calStruct.backgroundDependenceSetup.bgSettings;
        
    elseif (strcmp(oldStyleCalFieldName, 'bgmeas.settings'))
        fieldValue          = calStruct.backgroundDependenceSetup.settings;
        
    elseif (strcmp(oldStyleCalFieldName, 'bgmeas.spectra'))
        trialsNum           = size(calStruct.rawData.gammaCurveMeasurements,1);
        primariesNum        = size(calStruct.rawData.gammaCurveMeasurements,2); 
        gammaSamples        = size(calStruct.rawData.gammaCurveMeasurements,3); 
        spectralSamples     = size(calStruct.rawData.gammaCurveMeasurements,4);
    
        backgroundSettingsNum = size(calStruct.backgroundDependenceSetup.bgSettings,2);
        targetSettingsNum     = size(calStruct.backgroundDependenceSetup.settings,2);
    
        for backgroundSettingsIndex = 1:backgroundSettingsNum
            tmp = zeros(spectralSamples,targetSettingsNum); 
            for targetSettingsIndex = 1: targetSettingsNum
                tmp(:, targetSettingsIndex) = ...
                reshape(squeeze(calStruct.rawData.backgroundDependenceMeasurements(backgroundSettingsIndex, targetSettingsIndex, :)), ...
                [spectralSamples  1] );
            end
            fieldValue{backgroundSettingsIndex} = tmp;
        end
    
    % ------------ cal.basicmeas struct (in old format) -----------------
     elseif (strcmp(oldStyleCalFieldName, 'basicmeas.settings'))
        fieldValue = calStruct.basicLinearitySetup.settings;
        
     elseif (strcmp(oldStyleCalFieldName, 'basicmeas.spectra1'))
        fieldValue = calStruct.rawData.basicLinearityMeasurements1';
        
     elseif (strcmp(oldStyleCalFieldName, 'basicmeas.spectra2'))
        fieldValue = calStruct.rawData.basicLinearityMeasurements2';
        

    % ------------------ cal.processedData ---------------------
    
    elseif strcmp(oldStyleCalFieldName, 'gammaTable')
        fieldNameFullPath = 'processedData.gammaTable';
        
    elseif strcmp(oldStyleCalFieldName, 'gammaInput')
        fieldNameFullPath = 'processedData.gammaInput';
    
    elseif strcmp(oldStyleCalFieldName, 'gammaFormat')
        fieldNameFullPath = 'processedData.gammaFormat';
        
    elseif strcmp(oldStyleCalFieldName, 'monSVs')
        fieldNameFullPath = 'processedData.monSVs';
        
    elseif strcmp(oldStyleCalFieldName, 'P_device')
        fieldNameFullPath = 'processedData.P_device';
        
    elseif strcmp(oldStyleCalFieldName, 'T_device')
        fieldNameFullPath = 'processedData.T_device';
        
    elseif strcmp(oldStyleCalFieldName, 'S_device')
        fieldNameFullPath = 'processedData.S_device';
        
    elseif strcmp(oldStyleCalFieldName, 'P_ambient')
        fieldNameFullPath = 'processedData.P_ambient';
        
    elseif strcmp(oldStyleCalFieldName, 'T_ambient')  
        fieldNameFullPath = 'processedData.T_ambient';
        
    elseif strcmp(oldStyleCalFieldName, 'S_ambient') 
        fieldNameFullPath = 'processedData.S_ambient';
        
    elseif strcmp(oldStyleCalFieldName, 'T_sensor')         % This should be in runTime substruct
        fieldNameFullPath = 'processedData.T_sensor';
        
    elseif strcmp(oldStyleCalFieldName, 'S_sensor')         % This should be in runTime substruct
        fieldNameFullPath = 'processedData.S_sensor';
        
    elseif strcmp(oldStyleCalFieldName, 'T_linear')         % This should be in runTime substruct
        fieldNameFullPath = 'processedData.T_linear';
        
    elseif strcmp(oldStyleCalFieldName, 'S_linear')         % This should be in runTime substruct
        fieldNameFullPath = 'processedData.S_linear';

    elseif strcmp(oldStyleCalFieldName, 'M_device_linear')  % This should be in runTime substruct
        fieldNameFullPath = 'processedData.M_device_linear';
       
    elseif strcmp(oldStyleCalFieldName, 'M_linear_device')  % This should be in runTime substruct
        fieldNameFullPath = 'processedData.M_linear_device';
    
    elseif strcmp(oldStyleCalFieldName, 'M_ambient_linear')  % This should be in runTime substruct
        fieldNameFullPath = 'processedData.M_ambient_linear';

    elseif strcmp(oldStyleCalFieldName, 'ambient_linear')  % This should be in runTime substruct
        fieldNameFullPath = 'processedData.ambient_linear';

    elseif strcmp(oldStyleCalFieldName, 'gammaMode')     % This should be in runTime substruct
        fieldNameFullPath = 'processedData.gammaMode';
        
    elseif strcmp(oldStyleCalFieldName,'iGammaTable')   % This should be in runTime substruct
        fieldNameFullPath = 'processedData.iGammaTable';
        
    else
        fprintf(2,'Could not find equivalent field in the new calStruct for the old calStruct.%s. Returning empty value.\n', oldStyleCalFieldName);
    end
end
