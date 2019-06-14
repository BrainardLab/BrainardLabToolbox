function setDisplaysInitialState(obj, userPrompt)

    mglClose();
    
    % Make a local copy of obj.cal so we do not keep calling it and regenerating it
    calStruct = obj.cal;
    
    %  Get identity clut if useBitsPP is enabled
    if ((calStruct.describe.useBitsPP) && (isempty(obj.identityGammaForBitsPP)))
        % Linearize a bits plus box if it in the video chain.  Harmless
        % if there is no Bits++ and eliminates ambiguity if there is
        % a Bits++ box but we're not using it.
        mglBitsResetScreen(calStruct.describe.whichScreen);

        % Gets the OpenGL info on this machine.
        openGLData = opengl('data');

        % Look to see what video card we're using, and choose the identity gamma
        % accordingly.  Fix this someday to call a central routine
        switch openGLData.Renderer
            case 'NVIDIA GeForce GT 120 OpenGL Engine'
                obj.identityGammaForBitsPP = linspace(0, 1023/1024, 256)' * [1 1 1];

            otherwise
                obj.identityGammaForBitsPP = linspace(0, 1, 256)' * [1 1 1];
        end % switch
    end % if (calStruct.config.useBitsPP)
    
    % Blank other screen. 
    if calStruct.describe.blankOtherScreen
        mglSwitchDisplay(calStruct.describe.whichBlankScreen);
        mglOpen(calStruct.describe.whichBlankScreen);
        mglScreenCoordinates;
        obj.loadClut(calStruct.describe.blankSettings, calStruct.describe.blankSettings, calStruct.describe.useBitsPP);
        % Make sure the cursor is displayed.
        mglDisplayCursor;
    end  % blackOtherScreen
    
    % Blank screen to be measured
    mglSwitchDisplay(calStruct.describe.whichScreen);
    mglSetParam('spoofFullScreen',1);
    mglOpen(calStruct.describe.whichScreen);
    mglScreenCoordinates;
    
    % Show calibrating square
    bgSettings     = calStruct.describe.bgColor;
    targetSettings = [1 1 1];
    obj.loadClut(bgSettings, targetSettings, calStruct.describe.useBitsPP);
    
    disp('Position radiometer and hit enter when ready');
    pause

    % Wait for user
    if (userPrompt) 
        fprintf('Pausing for %d seconds ...', calStruct.describe.leaveRoomTime);
        FlushEvents;
        % GetChar;
        WaitSecs(calStruct.describe.leaveRoomTime);
        fprintf(' done\n\n\n');
    end

end