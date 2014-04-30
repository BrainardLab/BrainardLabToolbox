function value = CalStructGet(calStruct, oldStyleCalStructFieldName)
% Function to return values of calStruct fields that follow either the old
% format or the new format (implemented in the @Calibrator class). The
% input fieldname corresponds to the one that appeared in old-format
% calStructs. This function is to be used by PTB-3 functions so that they
% remain agnostic as to the format (new or old) of the calStruct.
% 
% 4/21/2014   npc   Wrote it.
%
% Usage:
% -------------------------------------------------------------------------
% 1) Descriptive properties
% -------------------------------------------------------------------------
% calibrationType   = CalStructGet(calStruct, 'calibrationType');
% whichScreen       = CalStructGet(calStruct, 'whichScreen');
% blankOtherScreen  = CalStructGet(calStruct, 'blankOtherScreen');
% whichBlankScreen  = CalStructGet(calStruct, 'whichBlankScreen');
% blankSettings     = CalStructGet(calStruct, 'blankSettings');
% meterDistance     = CalStructGet(calStruct, 'meterDistance');
% monitor           = CalStructGet(calStruct, 'monitor');
% comment           = CalStructGet(calStruct, 'comment');
% gamma             = CalStructGet(calStruct, 'gamma');
% bgColor           = CalStructGet(calStruct, 'bgColor');
% fgColor           = CalStructGet(calStruct, 'fgColor');
% usebitspp         = CalStructGet(calStruct, 'usebitspp');
% nDevices          = CalStructGet(calStruct, 'nDevices');
% nPrimaryBases     = CalStructGet(calStruct, 'nPrimaryBases');
% leaveRoomTime     = CalStructGet(calStruct, 'leaveRoomTime');
% nAverage          = CalStructGet(calStruct, 'nAverage');
% nMeas             = CalStructGet(calStruct, 'nMeas');
% boxSize           = CalStructGet(calStruct, 'boxSize');
% boxOffsetX        = CalStructGet(calStruct, 'boxOffsetX');
% boxOffsetY        = CalStructGet(calStruct, 'boxOffsetY');
% HDRProjector      = CalStructGet(calStruct, 'HDRProjector');
% promptforname     = CalStructGet(calStruct, 'promptforname');
% whichMeterType    = CalStructGet(calStruct, 'whichMeterType');
% dacsize           = CalStructGet(calStruct, 'dacsize');
% svnInfo           = CalStructGet(calStruct, 'svnInfo');
% caltype           = CalStructGet(calStruct, 'caltype');
% computer          = CalStructGet(calStruct, 'computer');
% driver            = CalStructGet(calStruct, 'driver');
% hz                = CalStructGet(calStruct, 'hz');
% screenSizePixel   = CalStructGet(calStruct, 'screenSizePixel');
% displayDescription= CalStructGet(calStruct, 'displayDescription');
% who               = CalStructGet(calStruct, 'who');
% date              = CalStructGet(calStruct, 'date');
% program           = CalStructGet(calStruct, 'program');
%
% % Get the graphics engine (MGL, PTB-3, etc.).  This will be empty for an old-style calStruct
% graphicsEngine    = CalStructGet(calStruct, 'graphicsEngine');
%
% % Get the calStruct revision no. This will be empty for an old-style calStruct
% calStructRevisionNo = CalStructGet(calStruct, 'calStructRevisionNo');
%
% -------------------------------------------------------------------------
% 2) Raw data - related properties
% -------------------------------------------------------------------------
% % Get the spectral sampling vector
% S                 = CalStructGet(calStruct, 'S');
%
% % Get basic measurements - related properties
% settings          = CalStructGet(calStruct, 'basicmeas.settings');
% spectra1          = CalStructGet(calStruct, 'basicmeas.spectra1');
% spectra2          = CalStructGet(calStruct, 'basicmeas.spectra2');
%
% % Get background dependence measurements - related properties
% bgSettings        = CalStructGet(calStruct, 'bgmeas.bgSettings');
% settings          = CalStructGet(calStruct, 'bgmeas.settings');
% spectra           = CalStructGet(calStruct, 'bgmeas.spectra');
%
% % Get gamma measurement - related properties
% monSpd            = CalStructGet(calStruct, 'monSpd'); 
% monIndex          = CalStructGet(calStruct, 'monIndex');
% mon               = CalStructGet(calStruct, 'mon');
% monSVs            = CalStructGet(calStruct, 'monSVs');
% rawGammaTable     = CalStructGet(calStruct, 'rawGammaTable');
% rawGammaInput     = CalStructGet(calStruct, 'rawGammaInput');
%    
% -------------------------------------------------------------------------   
% 3) Processed data - related properties
% -------------------------------------------------------------------------
% gammaInput        = CalStructGet(calStruct, 'gammaInput');
% gammaFormat       = CalStructGet(calStruct, 'gammaFormat');
% gammaTable        = CalStructGet(calStruct, 'gammaTable');
% P_device          = CalStructGet(calStruct, 'P_device');
% T_device          = CalStructGet(calStruct, 'T_device');
% S_ambient         = CalStructGet(calStruct, 'S_ambient');
% P_ambient         = CalStructGet(calStruct, 'P_ambient');
% T_ambient         = CalStructGet(calStruct, 'T_ambient');
%
% 
% -------------------------------------------------------------------------   
% 4) Runtime properties (these are still in processed substruct)
% -------------------------------------------------------------------------
% T_sensor          = CalStructGet(calStruct, 'T_sensor');
% S_sensor          = CalStructGet(calStruct, 'S_sensor');
% T_linear          = CalStructGet(calStruct, 'T_linear');
% M_device_linear   = CalStructGet(calStruct, 'M_device_linear');
% S_linear          = CalStructGet(calStruct, 'S_linear');
% M_linear_device   = CalStructGet(calStruct, 'M_linear_device');
% M_ambient_linear  = CalStructGet(calStruct, 'M_ambient_linear');
% gammaMode         = CalStructGet(calStruct, 'gammaMode');
% iGammaTable       = CalStructGet(calStruct, 'iGammaTable');
%
% -------------------------------------------------------------------------
%
    if (CalStructHasNewStyleFormat(calStruct))        
        [fieldNameStructPath, fieldValue] = PathOrValueOfOldFieldNameFromNewCalStruct(calStruct, oldStyleCalStructFieldName);
        if isempty(fieldNameStructPath)
            value = fieldValue;
        else
            value = eval(sprintf('calStruct.%s;', fieldNameStructPath));
        end
    else
        fieldNameStructPath = FieldPathInOldCalStruct(calStruct, oldStyleCalStructFieldName, '');
        if ~isempty(fieldNameStructPath)
            value = eval(sprintf('calStruct.%s;', fieldNameStructPath));
        else
            value = [];
        end
    end
end