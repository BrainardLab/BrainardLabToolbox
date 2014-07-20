function radiometricStruct = MeasureRadiometricDistributionOfScene(obj, whichMeterType, isFirstTrial)
% Method for measuring the radiometric distribution at a scene location. This is used in
% Debug Mode only to make sure that the rendered stimuli have the
% desired spectral characteristics
% 
% History: 
%  4/14/2013   ar   Wrote it
%

    % initialize response structure. 
    radiometricStruct = struct;

    switch whichMeterType
         case {0,1,4}
             radiometricStruct.radS = [380 4 101];
         case 2
             radiometricStruct.radS = [380 1 401];
         case 5
             radiometricStruct.radS = [380 2 201];
        otherwise
            error('Unknown meter type entered');
    end
    
    % render scene
    obj.showStimulus();
    
    
    if (isFirstTrial)
        
        message = struct;
        message.text = 'Aim the radiometer at the target. Hit any key when ready.';
        message.fontSize = 65;
        message.center = [0 -10];
        message.colorRGB = [1.0 0. 0.1];
        
%        obj.hideStereoCursor;
%        obj.showRadiometerBox;
       % obj.showMessage(message);
        fprintf('Aim the radiometer at the center of the target\n');
        fprintf('Hit any key when ready.');
        
        ListenChar;
        FlushEvents;
        GetChar;
    %    obj.hideRadiometerBox;
        %obj.hideMessage();
        fprintf('Pausing for 10 secs');
        WaitSecs(10);
    end
    tic
    radiometricStruct.data = MeasSpd(radiometricStruct.radS, whichMeterType);
    toc
end

