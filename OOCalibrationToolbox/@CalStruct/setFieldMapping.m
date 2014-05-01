function setFieldMapping(obj)
    % Contruct an empty map that will hold the values of the different fields
    obj.oldFormatFieldMap = containers.Map;
    
    % Contruct an empty map that will hold the struct paths of the different fields
    obj.calStructPathMap = containers.Map;
    
    % Fill the maps
    if obj.inputCalHasNewStyleFormat
        % Set a mapping from new-format field names -> old-format field names
        fprintf('Generating mapping from new-format fields -> old-format fields ...\n');
        
        % General info
        [obj.oldFormatFieldMap('computer'),         obj.calStructPathMap('computer')]   = obj.retrieveFieldFromStruct('describe', 'computerInfo');
        [obj.oldFormatFieldMap('svnInfo'),          obj.calStructPathMap('svnInfo')]    = obj.makeOldStyleSVNInfo();
        [obj.oldFormatFieldMap('monitor'),          obj.calStructPathMap('monitor')]    = obj.retrieveFieldFromStruct('describe', 'displayDeviceName');
        [obj.oldFormatFieldMap('caltype'),          obj.calStructPathMap('caltype')]    = obj.retrieveFieldFromStruct('describe', 'displayDeviceType');
        [obj.oldFormatFieldMap('driver'),           obj.calStructPathMap('driver')]  	= obj.retrieveFieldFromStruct('describe', 'driver');
        [obj.oldFormatFieldMap('who'),              obj.calStructPathMap('who')]      	= obj.retrieveFieldFromStruct('describe', 'who');
        [obj.oldFormatFieldMap('date'),             obj.calStructPathMap('date')]      	= obj.retrieveFieldFromStruct('describe', 'date');
        [obj.oldFormatFieldMap('program'),          obj.calStructPathMap('program')] 	= obj.retrieveFieldFromStruct('describe', 'executiveScriptName');
        [obj.oldFormatFieldMap('comment'),          obj.calStructPathMap('comment')] 	= obj.retrieveFieldFromStruct('describe', 'comment');
        
        obj.oldFormatFieldMap('calibrationType')    = [];  % This has been eliminated in OOC calibration as potentially confusing and un-necessary.
        obj.calStructPathMap('calibrationType')     = [];  % This has been eliminated in OOC calibration as potentially confusing and un-necessary.
        obj.oldFormatFieldMap('promptforname')      = [];  % This has been eliminated in OOC calibration as un-necessary 
        obj.calStructPathMap('promptforname')       = [];  % This has been eliminated in OOC calibration as un-necessary 
        
         
        % Screen configuration   
        [obj.oldFormatFieldMap('whichScreen'),      obj.calStructPathMap('whichScreen')]        = obj.retrieveFieldFromStruct('describe', 'whichScreen');
        [obj.oldFormatFieldMap('blankOtherScreen'), obj.calStructPathMap('blankOtherScreen')]   = obj.retrieveFieldFromStruct('describe', 'blankOtherScreen');
        [obj.oldFormatFieldMap('whichBlankScreen'), obj.calStructPathMap('whichBlankScreen')]   = obj.retrieveFieldFromStruct('describe', 'whichBlankScreen');
        [obj.oldFormatFieldMap('blankSettings'),    obj.calStructPathMap('blankSettings')]      = obj.retrieveFieldFromStruct('describe', 'blankSettings');
        [obj.oldFormatFieldMap('dacsize'),          obj.calStructPathMap('dacsize')]            = obj.retrieveFieldFromStruct('describe', 'dacsize');
        [obj.oldFormatFieldMap('hz'),               obj.calStructPathMap('hz')]                 = obj.retrieveFieldFromStruct('describe', 'hz');
        [obj.oldFormatFieldMap('screenSizePixel'),  obj.calStructPathMap('screenSizePixel')]    = obj.retrieveFieldFromStruct('describe', 'screenSizePixel');
        [displaysDescription, obj.calStructPathMap('displayDescription')] = obj.retrieveFieldFromStruct('describe', 'displaysDescription');
        if ((~isempty(displaysDescription)) && (~isempty(obj.oldFormatFieldMap('whichScreen'))))
            obj.oldFormatFieldMap('displayDescription') = displaysDescription(obj.oldFormatFieldMap('whichScreen'));
        else
            obj.oldFormatFieldMap('displayDescription') = [];
            obj.calStructPathMap('displayDescription')  = [];
        end
        obj.oldFormatFieldMap('HDRProjector')       = [];   % This has been eliminated in OOC calibration as we do not think we will be using the HDR projector any more.
        obj.calStructPathMap('HDRProjector')        = [];   % This has been eliminated in OOC calibration as we do not think we will be using the HDR projector any more.
       
        
        
        % Calibration params
        [obj.oldFormatFieldMap('boxSize'),          obj.calStructPathMap('boxSize')]            = obj.retrieveFieldFromStruct('describe', 'boxSize');
        [obj.oldFormatFieldMap('boxOffsetX'),       obj.calStructPathMap('boxOffsetX')]         = obj.retrieveFieldFromStruct('describe', 'boxOffsetX');
        [obj.oldFormatFieldMap('boxOffsetY'),       obj.calStructPathMap('boxOffsetY')]         = obj.retrieveFieldFromStruct('describe', 'boxOffsetY');
        [obj.oldFormatFieldMap('bgColor'),          obj.calStructPathMap('bgColor')]            = obj.retrieveFieldFromStruct('describe', 'bgColor');
        [obj.oldFormatFieldMap('fgColor'),          obj.calStructPathMap('fgColor')]            = obj.retrieveFieldFromStruct('describe', 'fgColor');
        [obj.oldFormatFieldMap('usebitspp'),        obj.calStructPathMap('usebitspp')]          = obj.retrieveFieldFromStruct('describe', 'useBitsPP');         
        [obj.oldFormatFieldMap('nDevices'),         obj.calStructPathMap('nDevices')]           = obj.retrieveFieldFromStruct('describe', 'displayPrimariesNum');
        [obj.oldFormatFieldMap('nPrimaryBases'),    obj.calStructPathMap('nPrimaryBases')]      = obj.retrieveFieldFromStruct('describe', 'primaryBasesNum');
        [obj.oldFormatFieldMap('nAverage'),         obj.calStructPathMap('nAverage')]           = obj.retrieveFieldFromStruct('describe', 'nAverage');
        [obj.oldFormatFieldMap('nMeas'),            obj.calStructPathMap('nMeas')]              = obj.retrieveFieldFromStruct('describe', 'nMeas');
        
        % Gamma related params
        [obj.oldFormatFieldMap('gamma'),            obj.calStructPathMap('gamma')]               = obj.retrieveFieldFromStruct('describe', 'gamma');
        [obj.oldFormatFieldMap('gamma.fitType'),    obj.calStructPathMap('gamma.fitType')]       = obj.retrieveFieldFromStruct('describe.gamma', 'fitType');
        if strcmp(obj.oldFormatFieldMap('gamma.fitType'), 'simplePower')
            [obj.oldFormatFieldMap('gamma.exponents'), obj.calStructPathMap('gamma.exponents')]  = obj.retrieveFieldFromStruct('describe.gamma', 'exponents');
        end
        
        % Radiometer params
        [obj.oldFormatFieldMap('leaveRoomTime'),    obj.calStructPathMap('leaveRoomTime')]      = obj.retrieveFieldFromStruct('describe', 'leaveRoomTime');
        [obj.oldFormatFieldMap('meterDistance'),    obj.calStructPathMap('meterDistance')]      = obj.retrieveFieldFromStruct('describe', 'meterDistance');
        [obj.oldFormatFieldMap('whichMeterType'),   obj.calStructPathMap('whichMeterType')]     = obj.makeOldStyleMeterType();
    
        % Raw data
        [obj.oldFormatFieldMap('S'),                obj.calStructPathMap('S')]                  = obj.retrieveFieldFromStruct('rawData', 'S');
        [obj.oldFormatFieldMap('monIndex'),         obj.calStructPathMap('monIndex')]           = obj.makeOldStyleMonIndex();
        [obj.oldFormatFieldMap('monSpd'),           obj.calStructPathMap('monSpd')]             = obj.makeOldStyleMonSpd();
        [obj.oldFormatFieldMap('mon'),              obj.calStructPathMap('mon')]                = obj.makeOldStyleMon();
        [obj.oldFormatFieldMap('rawGammaTable'),    obj.calStructPathMap('rawGammaTable')]      = obj.retrieveFieldFromStruct('rawData', 'gammaTable');
        [obj.oldFormatFieldMap('rawGammaInput'),    obj.calStructPathMap('rawGammaInput')]      = obj.makeOldStyleRawGammaInput();
        
        
        
        % Basic linearity measurements
        obj.oldFormatFieldMap('basicmeas.settings') = obj.retrieveFieldFromStruct('basicLinearitySetup', 'settings');
        obj.oldFormatFieldMap('bgmeas.spectra1')    = (obj.retrieveFieldFromStruct('rawData', 'basicLinearityMeasurements1')');
        obj.oldFormatFieldMap('bgmeas.spectra2')    = (obj.retrieveFieldFromStruct('rawData', 'basicLinearityMeasurements2')');

        
        % Background dependence measurements
        obj.oldFormatFieldMap('bgmeas.bgSettings')  = obj.retrieveFieldFromStruct('backgroundDependenceSetup', 'bgSettings');
        obj.oldFormatFieldMap('bgmeas.settings')    = obj.retrieveFieldFromStruct('backgroundDependenceSetup', 'settings');
        obj.oldFormatFieldMap('bgmeas.spectra')     = obj.makeBgMeasSpectra();


        % Processed data
        obj.oldFormatFieldMap('monSVs')             = obj.retrieveFieldFromStruct('processedData', 'monSVs');
        obj.oldFormatFieldMap('gammaFormat')        = obj.retrieveFieldFromStruct('processedData', 'gammaFormat');
        obj.oldFormatFieldMap('S_device')           = obj.retrieveFieldFromStruct('processedData', 'S_device');
        obj.oldFormatFieldMap('P_device')           = obj.retrieveFieldFromStruct('processedData', 'P_device');
        obj.oldFormatFieldMap('T_device')           = obj.retrieveFieldFromStruct('processedData', 'T_device');
        obj.oldFormatFieldMap('gammaInput')         = obj.retrieveFieldFromStruct('processedData', 'gammaInput');
        obj.oldFormatFieldMap('gammaTable')         = obj.retrieveFieldFromStruct('processedData', 'gammaTable');
        obj.oldFormatFieldMap('P_ambient')          = obj.retrieveFieldFromStruct('processedData', 'P_ambient');
        obj.oldFormatFieldMap('T_ambient')          = obj.retrieveFieldFromStruct('processedData', 'T_ambient');
        obj.oldFormatFieldMap('S_ambient')          = obj.retrieveFieldFromStruct('processedData', 'S_ambient');

        
    else
        % Set an identity mapping
        fprintf('Generating identity field mapping\n');
        
        % General info
        obj.oldFormatFieldMap('computer')           = obj.retrieveFieldFromStruct('describe', 'computer'); 
        obj.oldFormatFieldMap('svnInfo')            = obj.retrieveFieldFromStruct('describe', 'svnInfo');
        obj.oldFormatFieldMap('monitor')            = obj.retrieveFieldFromStruct('describe', 'monitor');
        obj.oldFormatFieldMap('caltype')            = obj.retrieveFieldFromStruct('describe', 'caltype');
        obj.oldFormatFieldMap('calibrationType')    = obj.retrieveFieldFromStruct('describe', 'calibrationType');
        obj.oldFormatFieldMap('driver')             = obj.retrieveFieldFromStruct('describe', 'driver');
        obj.oldFormatFieldMap('who')                = obj.retrieveFieldFromStruct('describe', 'who');
        obj.oldFormatFieldMap('promptforname')      = obj.retrieveFieldFromStruct('describe', 'promptforname');
        obj.oldFormatFieldMap('date')               = obj.retrieveFieldFromStruct('describe', 'date');
        obj.oldFormatFieldMap('program')            = obj.retrieveFieldFromStruct('describe', 'program');
        obj.oldFormatFieldMap('comment')            = obj.retrieveFieldFromStruct('describe', 'comment');
        
        % Screen configuration  
        obj.oldFormatFieldMap('whichScreen')        = obj.retrieveFieldFromStruct('describe', 'whichScreen');
        obj.oldFormatFieldMap('displayDescription') = obj.retrieveFieldFromStruct('describe', 'displayDescription');
        obj.oldFormatFieldMap('blankOtherScreen')   = obj.retrieveFieldFromStruct('describe', 'blankOtherScreen');
        obj.oldFormatFieldMap('whichBlankScreen')   = obj.retrieveFieldFromStruct('describe', 'whichBlankScreen');
        obj.oldFormatFieldMap('blankSettings')      = obj.retrieveFieldFromStruct('describe', 'blankSettings');
        obj.oldFormatFieldMap('HDRProjector')       = obj.retrieveFieldFromStruct('describe', 'HDRProjector');
        obj.oldFormatFieldMap('dacsize')            = obj.retrieveFieldFromStruct('describe', 'dacsize');
        obj.oldFormatFieldMap('hz')                 = obj.retrieveFieldFromStruct('describe', 'hz');
        obj.oldFormatFieldMap('screenSizePixel')    = obj.retrieveFieldFromStruct('describe', 'screenSizePixel');
       
        % Calibration params
        obj.oldFormatFieldMap('boxSize')            = obj.retrieveFieldFromStruct('describe', 'boxSize');
        obj.oldFormatFieldMap('boxOffsetX')         = obj.retrieveFieldFromStruct('describe', 'boxOffsetX');
        obj.oldFormatFieldMap('boxOffsetY')         = obj.retrieveFieldFromStruct('describe', 'boxOffsetY');
        obj.oldFormatFieldMap('bgColor')            = obj.retrieveFieldFromStruct('', 'bgColor');
        obj.oldFormatFieldMap('fgColor')            = obj.retrieveFieldFromStruct('', 'fgColor');
        obj.oldFormatFieldMap('usebitspp')          = obj.retrieveFieldFromStruct('', 'usebitspp');         
        obj.oldFormatFieldMap('nDevices')           = obj.retrieveFieldFromStruct('', 'nDevices');
        obj.oldFormatFieldMap('nPrimaryBases')      = obj.retrieveFieldFromStruct('', 'nPrimaryBases');
        obj.oldFormatFieldMap('nAverage')           = obj.retrieveFieldFromStruct('describe', 'nAverage');
        obj.oldFormatFieldMap('nMeas')              = obj.retrieveFieldFromStruct('describe', 'nMeas');
        
        % Gamma related params
        obj.oldFormatFieldMap('gamma')              = obj.retrieveFieldFromStruct('describe', 'gamma');
        obj.oldFormatFieldMap('gamma.fitType')      = obj.retrieveFieldFromStruct('describe.gamma', 'fitType');
        if strcmp(obj.oldFormatFieldMap('gamma.fitType'), 'simplePower')
            obj.oldFormatFieldMap('gamma.exponents') = obj.retrieveFieldFromStruct('describe.gamma', 'exponents');
        end
        
        % Radiometer params
        obj.oldFormatFieldMap('leaveRoomTime')      = obj.retrieveFieldFromStruct('describe', 'leaveRoomTime');
        obj.oldFormatFieldMap('meterDistance')      = obj.retrieveFieldFromStruct('describe', 'meterDistance');
        obj.oldFormatFieldMap('whichMeterType')     = obj.retrieveFieldFromStruct('describe', 'whichMeterType');
         
        % Raw data
        obj.oldFormatFieldMap('S')                  = obj.retrieveFieldFromStruct('describe', 'S');
        obj.oldFormatFieldMap('monIndex')           = obj.retrieveFieldFromStruct('rawdata', 'monIndex');
        obj.oldFormatFieldMap('monSpd')             = obj.retrieveFieldFromStruct('rawdata', 'monSpd');
        obj.oldFormatFieldMap('mon')                = obj.retrieveFieldFromStruct('rawdata', 'mon');
        obj.oldFormatFieldMap('rawGammaTable')      = obj.retrieveFieldFromStruct('rawdata', 'rawGammaTable');
        obj.oldFormatFieldMap('rawGammaInput')      = obj.retrieveFieldFromStruct('rawdata', 'rawGammaInput');
    
        % Basic linearity measurements
        obj.oldFormatFieldMap('basicmeas.settings') = obj.retrieveFieldFromStruct('basicmeas', 'settings');
        obj.oldFormatFieldMap('bgmeas.spectra1')    = obj.retrieveFieldFromStruct('basicmeas', 'spectra1');
        obj.oldFormatFieldMap('bgmeas.spectra2')    = obj.retrieveFieldFromStruct('basicmeas', 'spectra2');
        
        % Background dependence measurements
        obj.oldFormatFieldMap('bgmeas.bgSettings')  = obj.retrieveFieldFromStruct('bgmeas', 'bgSettings');
        obj.oldFormatFieldMap('bgmeas.settings')    = obj.retrieveFieldFromStruct('bgmeas', 'settings');
        obj.oldFormatFieldMap('bgmeas.spectra')     = obj.retrieveFieldFromStruct('bgmeas', 'spectra');
        
        % Processed data
        obj.oldFormatFieldMap('monSVs')             = obj.retrieveFieldFromStruct('rawdata', 'monSVs');
        obj.oldFormatFieldMap('gammaFormat')        = obj.retrieveFieldFromStruct('', 'gammaFormat');
        obj.oldFormatFieldMap('S_device')           = obj.retrieveFieldFromStruct('', 'S_device');
        obj.oldFormatFieldMap('P_device')           = obj.retrieveFieldFromStruct('', 'P_device');
        obj.oldFormatFieldMap('T_device')           = obj.retrieveFieldFromStruct('', 'T_device');
        obj.oldFormatFieldMap('gammaInput')         = obj.retrieveFieldFromStruct('', 'gammaInput');
        obj.oldFormatFieldMap('gammaTable')         = obj.retrieveFieldFromStruct('', 'gammaTable');
        obj.oldFormatFieldMap('P_ambient')          = obj.retrieveFieldFromStruct('', 'P_ambient');
        obj.oldFormatFieldMap('T_ambient')          = obj.retrieveFieldFromStruct('', 'T_ambient');
        obj.oldFormatFieldMap('S_ambient')          = obj.retrieveFieldFromStruct('', 'S_ambient');
               
    end
end