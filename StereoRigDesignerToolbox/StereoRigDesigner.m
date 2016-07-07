% Graphical user interface to the StereoGeometer class.
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.
%
function StereoRigDesigner    
    defaults.vergencePlaneWidth = 80;
    defaults.vergencePlaneHeight = 50;
    
    defaults.eyeSeparation = 6.4;
    defaults.viewingDistance = 76.4;
    defaults.mirrorWidth = 15.0;
    defaults.mirrorHeight = 15.0;
    defaults.mirrorRotation = 47.4;
    defaults.mirrorDistanceFromEyeNodalPoint = 10;
    defaults.mirrorOffset = 0.0;
    defaults.virtualStimulusWidth = 30;
    defaults.virtualStimulusHeight = 20;
    defaults.apertureDepth = 20;   % the negative of this value is used in the computations
    defaults.monitorRotation = -87.6;
    
    SONY_OLED_PVM2541 = struct(...
        'modelName', 'SONY OLED PVM 2541A', ...
        'diagonalSize', 62.34, ...
        'pixelsHeight', 1080, ...
        'pixelsWidth', 1920 ...
        );
        
    STEREO_LCD = struct(...
        'modelName', 'Stereo LCD', ...
        'diagonalSize', 61.08, ...
        'pixelsHeight', 1200, ...
        'pixelsWidth', 1920 ...
        );
    
    
    defaults.display = STEREO_LCD;
        
    % Struct with all the primary properties
    stereoRigState = struct(...
        'eyeSeparation',  defaults.eyeSeparation, ...
        'viewingDistance', defaults.viewingDistance, ...
        'vergencePlaneWidth', defaults.vergencePlaneWidth, ...
        'vergencePlaneHeight', defaults.vergencePlaneHeight, ...
        'virtualStimulusWidth', defaults.virtualStimulusWidth, ...
        'virtualStimulusHeight', defaults.virtualStimulusHeight, ...
        'apertureDepth', defaults.apertureDepth, ...
        'mirrorWidth',  defaults.mirrorWidth, ...
        'mirrorHeight', defaults.mirrorHeight, ...
        'mirrorDistanceFromEyeNodalPoint', defaults.mirrorDistanceFromEyeNodalPoint, ...
        'mirrorOffset', defaults.mirrorOffset, ...
        'mirrorRotationLeft', -defaults.mirrorRotation, ...
        'mirrorRotationRight', defaults.mirrorRotation, ...
        'monitorName', defaults.display.modelName, ...
        'monitorDiagonalSize', defaults.display.diagonalSize, ...
        'monitorPixelsHeight', defaults.display.pixelsHeight, ...
        'monitorPixelsWidth', defaults.display.pixelsWidth, ...
        'monitorDepthPosition', -66.4, ...
        'monitorHorizPosition', 69.4, ...
        'monitorRotationLeft', -defaults.monitorRotation, ...
        'monitorRotationRight', defaults.monitorRotation ...
        );
        

    figureNo = 1;
    windowSize = [1710 1125]; %[1920 1010];
    projectionType = 'perspective'; % 'orthographic'; % 'perspective'; 
    stereoGeometer = StereoGeometer(figureNo, windowSize, projectionType, 'Brainard Lab Stereo Rig');
    stereoGeometer.setState(stereoRigState);
   
   
    % configure GUI components
    % 0. TOP MENU
    configureMenu(stereoGeometer);
    
    
    % 1. RIGHT COLUMN OF BUTTONS
    configureInteractiveViewingButtons(stereoGeometer);
    
    % 2. LEFT COLUMN OF SLIDER ASSEMBLIES
    yBaseStep = 0.05;
    xBasePos = 0.005;
    yBasePos = 0.93;
    
    % 2oo. The viewing distance
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'eye separation (cm)', ...
        abs(stereoGeometer.eyeSeparation), ...
        [1.5 20.5], ...   % valid range
        defaults.eyeSeparation, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.eyeSeparation = newValue;' ...
        });
    
    % 2o. The viewing distance
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'viewing distance (cm)', ...
        abs(stereoGeometer.viewingDistance), ...
        [40 120], ...   % valid range
        defaults.viewingDistance, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.viewingDistance = newValue;' ...
        });
    
    % 2a. The mirror rotation gui assembly  
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'mirror rotation (deg)', ...
        abs(stereoGeometer.mirrorRotationRight), ...
        [20 60], ...   % valid range
        struct(...
            'className', 'StereoGeometer', ...
            'functionName', 'computeDefaultMirrorAngleBasedOnEyeSeparation'...
        ), ...
        'F(es,vd) ', ...
        { 'stereoGeometer.stereoRigState.mirrorRotationRight = newValue;' ...
          'stereoGeometer.stereoRigState.mirrorRotationLeft = -stereoGeometer.stereoRigState.mirrorRotationRight;' ...
        });

    
    % 2b. The mirror width gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'mirror width (cm)', ...
        abs(stereoGeometer.mirrorWidth), ...
        [2 40], ...   % valid range
        defaults.mirrorWidth, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.mirrorWidth = newValue;'...
        });
    
    
    % 2c. The mirror height gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'mirror height (cm)', ...
        abs(stereoGeometer.mirrorHeight), ...
        [2 40], ...   % valid range
        defaults.mirrorHeight, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.mirrorHeight = newValue;'...
        });


    % 2d. The mirror - nodal point distance gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'mirror-nodal point distance (cm)', ...
        abs(stereoGeometer.mirrorDistanceFromEyeNodalPoint), ...
        [2 40], ...   % valid range
        defaults.mirrorDistanceFromEyeNodalPoint, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.mirrorDistanceFromEyeNodalPoint = newValue;'...
        });
    
    % 2e. The mirror offset gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'mirror offset (cm)', ...
        abs(stereoGeometer.mirrorOffset), ...
        [0 20], ...   % valid range
        defaults.mirrorOffset, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.mirrorOffset = newValue;'...
        });
    
    % 2f. The virtual stimulus width gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'max virtual scene width (cm)', ...
        abs(stereoGeometer.virtualStimulusWidth), ...
        [5 60], ...   % valid range
        defaults.virtualStimulusWidth, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.virtualStimulusWidth = newValue;'...
        });
  
    % 2g. The virtual stimulus height gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'max virtual scene height (cm)', ...
        abs(stereoGeometer.virtualStimulusHeight), ...
        [5 40], ...   % valid range
        defaults.virtualStimulusHeight, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.virtualStimulusHeight = newValue;'...
        });
   
    % 2h. The aperture depth gui assembly
    yBasePos = yBasePos-yBaseStep;
    configureSliderButtonEditAssembly(...
        xBasePos, ...
        yBasePos, ...
        stereoGeometer, ...
        'max virtual scene depth (cm)', ...
        abs(stereoGeometer.apertureDepth), ...
        [1 45], ...   % valid range
        defaults.apertureDepth, ...
        ' default ', ...
        { 'stereoGeometer.stereoRigState.apertureDepth = newValue;'...
        });
    
    % Finally set the monitor position/rotation outlets (read-only)
    
    yBaseStep = 0.027;
    yBasePos = 0.96;
    
    % 1st row
    xBasePos = 0.316;
    leftMonitorPositionOutlet = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'leftDisplayPositionOutletUseAlternateDisplay', 'left display position', 'left display position');
    
    xBasePos = xBasePos + 0.21;
    rightMonitorPositionOutlet = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'rightDisplayPositionOutletUseAlternateDisplay', 'right display position', 'right display position');
    
    % 2nd row
    yBasePos = yBasePos - yBaseStep; xBasePos = 0.316;
    leftMonitorRotationOutlet = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'leftMonitorRotationOutletUseAlternateDisplay', 'left display rotation', 'left display rotation');
    
    xBasePos = xBasePos + 0.21;
    rightMonitorRotationOutlet  = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'rightMonitorRotationOutletUseAlternateDisplay', 'right display rotation', 'right display rotation');
    
    % 3rd row
    yBasePos = yBasePos - yBaseStep; xBasePos = 0.316;
    leftMirrorPositionOutlet  = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'leftMirrorPositionOutletUseAlternateDisplay', 'left mirror position', 'left mirror position');
    
    xBasePos = xBasePos + 0.21;
    rightMirrorPositionOutlet  = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'rightMirrorPositionOutletUseAlternateDisplay', 'right mirror position', 'right mirror position');
    
    % 4th row
    yBasePos = yBasePos - yBaseStep; xBasePos = 0.316;
    aperturePositionOutlet  = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'aperturePositionOutletUseAlternateDisplay', 'aperture position', 'aperture position');
    
    xBasePos = xBasePos + 0.21;
    apertureSizeOutlet = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, 'apertureSizeOutletUseAlternateDisplay', 'aperture size (cm)', 'aperture size (deg)');
    
    outletsStruct = struct(...
        'leftMonitorPositionOutlet', leftMonitorPositionOutlet, ...
        'leftMonitorRotationOutlet', leftMonitorRotationOutlet, ...
        'rightMonitorPositionOutlet', rightMonitorPositionOutlet, ...
        'rightMonitorRotationOutlet', rightMonitorRotationOutlet, ...
        'leftMirrorPositionOutlet',  leftMirrorPositionOutlet, ...
        'rightMirrorPositionOutlet', rightMirrorPositionOutlet, ...
        'aperturePositionOutlet', aperturePositionOutlet, ...
        'apertureSizeOutlet', apertureSizeOutlet ...
        );
    
    stereoGeometer.setOutlets(outletsStruct);
    
    % Generate the scene from scratch
    
    stereoGeometer.setView('defaultView');
    stereoGeometer.redrawScene();
    set(stereoGeometer.window, 'Visible','On');
    
end



function configureMenu(stereoGeometer)
    mainMenu1 = uimenu(stereoGeometer.window, 'Label', 'File Ops ...'); 
                uimenu(mainMenu1, 'Label', 'Save configuration',   'Callback', {@saveConfigutation_Callback, stereoGeometer});
    subMenu12 = uimenu(mainMenu1, 'Label', 'Export scene as ... ');
    subMenu121= uimenu(subMenu12, 'Label', 'PDF doc ...' );
                uimenu(subMenu121, 'Label', 'including the uicontrols', 'Callback', {@exportGraphic_Callback, stereoGeometer, 'PDF', true});
                uimenu(subMenu121, 'Label', 'without the uicontrols', 'Callback', {@exportGraphic_Callback, stereoGeometer, 'PDF', false});
    subMenu122 = uimenu(subMenu12, 'Label', 'PNG doc');
                uimenu(subMenu122, 'Label', 'including the uicontrols', 'Callback', {@exportGraphic_Callback, stereoGeometer, 'PNG', true});
                uimenu(subMenu122, 'Label', 'without the uicontrols', 'Callback', {@exportGraphic_Callback, stereoGeometer, 'PNG', false});
             
    mainMenu2  = uimenu(stereoGeometer.window, 'Label', 'Frustum visualization options ... ');
    subMenu21 = uimenu(mainMenu2, 'Label', '1. Select stimulus ocularity ... ');
                uimenu(subMenu21, 'Label', 'Monocular', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'monocular'});
                uimenu(subMenu21, 'Label', 'Binocular component', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'binocular'});
    subMenu22 = uimenu(mainMenu2, 'Label', '2. Select path ... ');
                uimenu(subMenu22, 'Label', 'Only for left path', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'left path'});
                uimenu(subMenu22, 'Label', 'Only for right path', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'right path'});
                uimenu(subMenu22, 'Label', 'Both left and right paths', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'left and right path'});
                uimenu(subMenu22, 'Label', 'None', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'none'});
    subMenu23 = uimenu(mainMenu2, 'Label', '3. Select fill/stroke ... ');   
                uimenu(subMenu23, 'Label', 'Stroke and Fill', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'stroke and fill'});
                uimenu(subMenu23, 'Label', 'Stroke only', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'stroke only'});
                uimenu(subMenu23, 'Label', 'Fill only', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'fill only'});
    subMenu24 = uimenu(mainMenu2, 'Label', '4. Show real frustum only (i.e., do not show the virtual component) ... ');
                uimenu(subMenu24, 'Label', 'ON', 'Callback',  {@viewFrustums_Callback, stereoGeometer, 'Real frustum only'});
                uimenu(subMenu24, 'Label', 'OFF', 'Callback', {@viewFrustums_Callback, stereoGeometer, 'Real and virtual frusta'});
                
                
    mainMenu3 = uimenu(stereoGeometer.window, 'Label', 'Windowing for non-rivalrous stereo imagery ...');
    subMenu31 = uimenu(mainMenu3, 'Label', 'Aperture plane ... ');
                uimenu(subMenu31, 'Label', 'ON', 'Callback', {@aperturePlane_Callback, stereoGeometer, 'ON'});
                uimenu(subMenu31, 'Label', 'OFF', 'Callback', {@aperturePlane_Callback, stereoGeometer, 'OFF'});
    subMenu32 = uimenu(mainMenu3, 'Label', 'Scene enclosing room ... ');
                uimenu(subMenu32, 'Label', 'ON', 'Callback', {@enclosingRoom_Callback, stereoGeometer, 'ON'});
                uimenu(subMenu32, 'Label', 'OFF', 'Callback', {@enclosingRoom_Callback, stereoGeometer, 'OFF'});
                uimenu(subMenu32, 'Label', 'Semi-transparent', 'Callback', {@enclosingRoom_Callback, stereoGeometer, 'SEMITRANSPARENT'});
                
    mainMenu4 = uimenu(stereoGeometer.window, 'Label', 'Viewing options ...');
    subMenu41 = uimenu(mainMenu4, 'Label', 'Camera position... ');
                uimenu(subMenu41, 'Label', 'Top view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'TOP VIEW'});
                uimenu(subMenu41, 'Label', 'Front view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'FRONT VIEW'});
                uimenu(subMenu41, 'Label', 'Horizontal view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'HORIZONTAL VIEW'});
                uimenu(subMenu41, 'Label', 'Left side view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'LEFTSIDE VIEW'});
                uimenu(subMenu41, 'Label', 'Right side view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'RIGHTSIDE VIEW'});
                uimenu(subMenu41, 'Label', 'Back wall view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'BACKWALL VIEW'});
                
                uimenu(subMenu41, 'Label', 'Default view', 'Callback', {@cameraPosition_Callback, stereoGeometer, 'DEFAULT VIEW'});
                
                
    subMenu42 = uimenu(mainMenu4, 'Label', 'Plane labels... ');
                uimenu(subMenu42, 'Label', 'ON', 'Callback', {@planeLabels_Callback, stereoGeometer, 'ON'});
                uimenu(subMenu42, 'Label', 'OFF', 'Callback', {@planeLabels_Callback, stereoGeometer, 'OFF'});
                
    subMenu43 = uimenu(mainMenu4, 'Label', 'Monitor projections on virtual stimulus plane ... ');
                uimenu(subMenu43, 'Label', 'ON', 'Callback',  {@monitorProjections_Callback, stereoGeometer, 'ON'});
                uimenu(subMenu43, 'Label', 'OFF', 'Callback', {@monitorProjections_Callback, stereoGeometer, 'OFF'});
                
    subMenu44 = uimenu(mainMenu4, 'Label', 'Label axes ... ');
                uimenu(subMenu44, 'Label', 'ON', 'Callback',  {@labelAxes_Callback, stereoGeometer, 'ON'});
                uimenu(subMenu44, 'Label', 'OFF', 'Callback', {@labelAxes_Callback, stereoGeometer, 'OFF'});
     
    function viewFrustums_Callback(source, callbackdata, stereoGeometer, whichOne)
        if (strcmp(whichOne, 'monocular'))
            stereoGeometer.showMonocularPaths = true;
        elseif (strcmp(whichOne, 'binocular'))
            stereoGeometer.showMonocularPaths = false;
        elseif (strcmp(whichOne, 'left path'))
            stereoGeometer.showLeftViewFrustum = true;
            stereoGeometer.showRightViewFrustum = false;
        elseif (strcmp(whichOne, 'right path'))
            stereoGeometer.showLeftViewFrustum = false;
            stereoGeometer.showRightViewFrustum = true;
        elseif (strcmp(whichOne, 'left and right path'))
            stereoGeometer.showLeftViewFrustum = true;
            stereoGeometer.showRightViewFrustum = true;
        elseif (strcmp(whichOne, 'none'))
            stereoGeometer.showLeftViewFrustum = false;
            stereoGeometer.showRightViewFrustum = false;
        elseif (strcmp(whichOne, 'stroke and fill'))
            stereoGeometer.strokeFrusta = true;
            stereoGeometer.fillFrusta = true;
        elseif (strcmp(whichOne, 'stroke only'))
            stereoGeometer.strokeFrusta = true;
            stereoGeometer.fillFrusta = false;
       elseif (strcmp(whichOne, 'fill only'))
            stereoGeometer.strokeFrusta = false;
            stereoGeometer.fillFrusta = true;
        elseif (strcmp(whichOne, 'Real frustum only'))
            stereoGeometer.showRealFrustumOnly = true;
        elseif (strcmp(whichOne, 'Real and virtual frusta'))
            stereoGeometer.showRealFrustumOnly = false;
        end
        stereoGeometer.redrawScene();
    end

    function cameraPosition_Callback(ource, callbackdata, stereoGeometer, state)
        if (strcmpi(state, 'TOP VIEW'))
            stereoGeometer.viewAngles = [0 90];
        elseif (strcmpi(state, 'FRONT VIEW'))
            stereoGeometer.viewAngles = [0 38];
        elseif (strcmpi(state, 'HORIZONTAL VIEW'))
            stereoGeometer.viewAngles = [0 0];
        elseif (strcmpi(state, 'LEFTSIDE VIEW'))
            stereoGeometer.viewAngles = [-90 0];
        elseif (strcmpi(state, 'RIGHTSIDE VIEW'))
            stereoGeometer.viewAngles = [90 0];
        elseif (strcmpi(state, 'BACKWALL VIEW'))
            stereoGeometer.viewAngles = [180 0];    
        elseif (strcmpi(state, 'DEFAULT VIEW'))
            stereoGeometer.viewAngles = stereoGeometer.defaultViewAngles;
            set(stereoGeometer.sceneView, 'CameraViewAngle', stereoGeometer.cameraViewAngle);
        end
        view(stereoGeometer.sceneView, stereoGeometer.viewAngles);
       % stereoGeometer.redrawScene();
    end


    function aperturePlane_Callback(source, callbackdata, stereoGeometer, state)
        if (strcmp(state, 'ON'))
            stereoGeometer.showAperturePlane = true;
            stereoGeometer.redrawScene();
        else
            stereoGeometer.showAperturePlane = false;
            stereoGeometer.redrawScene();
        end
    end

    function enclosingRoom_Callback(source, callbackdata, stereoGeometer, state)  
       stereoGeometer.showEnclosingRoom = state;
       stereoGeometer.redrawScene();
    end

    function labelAxes_Callback(source, callbackdata, stereoGeometer, state)  
       stereoGeometer.labelAxes = state;
       stereoGeometer.redrawScene();
    end

    function monitorProjections_Callback(source, callbackdata, stereoGeometer, state)
        if (strcmp(state, 'ON'))
            stereoGeometer.viewMonitorProjectionsOnVirtualStimulusPlane = true;
            stereoGeometer.redrawScene();
        else
            stereoGeometer.viewMonitorProjectionsOnVirtualStimulusPlane = false;
            stereoGeometer.redrawScene();
        end
    end

    function planeLabels_Callback(source, callbackdata, stereoGeometer, state)
        if (strcmp(state, 'ON'))
            stereoGeometer.labelBoundaryPoints = true;
            stereoGeometer.redrawScene();
        else
            stereoGeometer.labelBoundaryPoints = false;
            stereoGeometer.redrawScene();
        end
    end

    function saveConfigutation_Callback(source, callbackdata, stereoGeometer)
        fprintf('\nThis feature is not implemented yet.!\n');
        warndlg('This feature is not implemented yet. Email Nicolas P. Cottaris at cottaris@sas.upenn.edu','StereoRigDesigner');
    end

    function exportGraphic_Callback(source, callbackdata, stereoGeometer, fileFormat, includeUIcontrols) 
        
        if strcmp(fileFormat, 'PDF')
            fileName = 'StereoRig.pdf';
            [exportFileName, exportDirectory, filterIndex] = uiputfile(fileName, 'PDF file');
            if ((~isempty(exportFileName)) && (filterIndex > 0))
                pdfFileName = fullfile(exportDirectory,exportFileName);
            else
               return; 
            end
            dpi = 300;
            h = msgbox('Exporting to PDF. Please wait ...','PDF generation');
            pause(0.1);
            if (includeUIcontrols)
                NicePlot.exportFigToPDF(pdfFileName, stereoGeometer.window, dpi);
            else
                NicePlot.exportFigToPDF(pdfFileName, stereoGeometer.window, dpi, 'noui');
            end
            delete(h);
            
        elseif strcmp(fileFormat, 'PNG')
            fileName = 'StereoRig.png';
            [exportFileName, exportDirectory, filterIndex] = uiputfile(fileName, 'PNG file');
            if ((~isempty(exportFileName)) && (filterIndex > 0))
                pngFileName = fullfile(exportDirectory,exportFileName);
            else
               return; 
            end
            dpi = 400;
            h = msgbox('Exporting to PNG. Please wait ...','PNG generation');
            pause(0.1);
            if (includeUIcontrols)
                NicePlot.exportFigToPNG(pngFileName, stereoGeometer.window, dpi);
            else
                NicePlot.exportFigToPNG(pngFileName, stereoGeometer.window, dpi, 'noui');
            end
            delete(h);
        end
        stereoGeometer.redrawScene();
    end

end

function  propertyValueControl = configureEditAssembly(xBasePos, yBasePos, stereoGeometer, useAlternateDisplayFlag, propertyName, alternatePropertyName)

    propertyNameControl = uicontrol(...
        'Parent', stereoGeometer.window,...
        'BackgroundColor', [0.9 0.9 0.9], ...
        'ForegroundColor', [0.3 0.3 0.3], ...
        'Style', 'togglebutton',...
        'String', propertyName,...
        'Enable', 'on', ...
        'HorizontalAlignment', 'right', ...
        'FontSize', 14,...
        'Units', 'normalized',...
        'Position', [xBasePos, yBasePos 0.09 0.030]);
    
    propertyValueControl = uicontrol(...
        'Parent', stereoGeometer.window,...
        'String', '', ...
        'Enable', 'off', ...
        'Style', 'togglebutton',...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 0.9], ...
        'FontSize', 14,...
        'Units', 'normalized',...
        'Position', [xBasePos+0.087, yBasePos 0.12 0.030]);

    set(propertyNameControl, 'Callback', {@outputModifier, stereoGeometer, useAlternateDisplayFlag, propertyName, alternatePropertyName});
    
    function outputModifier(sourceControl, callbackdata, stereoGeometer,  useAlternateDisplayFlag, propertyName, alternatePropertyName)
        if (sourceControl.Value == 0)
            % default
            set(sourceControl, 'String', propertyName);
            stereoGeometer.(useAlternateDisplayFlag) = false;
        else
            % alternate
            set(sourceControl, 'String', alternatePropertyName);
            stereoGeometer.(useAlternateDisplayFlag) = true;
        end
        stereoGeometer.redrawScene;
    end

end

function  configureSliderButtonEditAssembly(xBasePos, yBasePos, stereoGeometer, propertyName, propertyValue, propertyRange, defaultPropertyValue, defaultButtonLabel, commandsToExecute)
        
    propertySlider = uicontrol(...
        'Parent', stereoGeometer.window,...
        'Style', 'slider',...
        'BackgroundColor', [0.3 0.3 0.5], ...
        'Min', propertyRange(1), 'Max', propertyRange(2), 'Value', propertyValue,...
        'Units', 'normalized',...
        'Position', [xBasePos,  yBasePos 0.15 0.03]);          
    set(propertySlider, 'SliderStep', 1.0/((propertySlider.Max-propertySlider.Min)*10)*[1 1]);
    
    propertyDefaultButton = uicontrol(...
        'Parent', stereoGeometer.window, ...
        'Style', 'pushbutton',...
        'ForegroundColor', [0.1 0.3 0.99], ...
        'String', defaultButtonLabel,...
        'FontSize', 16,...
        'FontWeight', 'b',...
        'Units', 'normalized',...
        'Position', [xBasePos + 0.155, yBasePos+0.016 0.06 0.044]);
    
    propertyEdit = uicontrol(...
        'Parent', stereoGeometer.window,...
        'String', sprintf('%2.1f', propertyValue), ...
        'Style', 'edit',...
        'BackgroundColor', [1 1 0.8], ...
        'HorizontalAlignment', 'right', ...
        'FontSize', 14,...
        'Units', 'normalized',...
        'Position', [xBasePos + 0.13, yBasePos+0.031 0.02 0.025]);
    
    propertyLabel = uicontrol(...
        'Parent', stereoGeometer.window,...
        'BackgroundColor', 0.85*[1 1 0.8], ...
        'Style', 'edit',...
        'String', propertyName,...
        'Enable', 'off', ...
        'HorizontalAlignment', 'right', ...
        'FontSize', 14,...
        'Units', 'normalized',...
        'Position', [xBasePos, yBasePos+0.031 0.13 0.025]);
                
    set(propertySlider, 'Callback', {@newPropertyValue, stereoGeometer, commandsToExecute, propertyEdit});  
    set(propertyEdit,   'Callback', {@newPropertyValue, stereoGeometer, commandsToExecute, propertySlider}); 
    set(propertyDefaultButton, 'Callback', {@newPropertyValue, stereoGeometer, commandsToExecute, propertySlider, propertyEdit, defaultPropertyValue});
    
    function newPropertyValue(source, callbackdata, stereoGeometer, commandsToExecute, counterpartGUI, varargin)
        updateIsGood = true;
        if (strcmp(source.Style, 'edit'))
            newValue = str2double(source.String);
            if ((newValue < counterpartGUI.Min) || (newValue > counterpartGUI.Max))
                updateIsGood = false;
                warndlg(sprintf('VALID RANGE = [%2.1f-%2.1f]', counterpartGUI.Min, counterpartGUI.Max), sprintf('Value %f is out of range!', newValue));
            else
                set(counterpartGUI, 'Value', newValue);
            end
        elseif(strcmp(source.Style, 'slider'))
            newValue = source.Value;
            set(counterpartGUI, 'String', sprintf('%2.1f', newValue));
        else
            if (isstruct(varargin{2})) && (isfield(varargin{2}, 'className')) && (isfield(varargin{2}, 'className'))
                if (strcmp(varargin{2}.className, 'StereoGeometer'))
                    newValue = stereoGeometer.(varargin{2}.functionName)();
                else
                    error('I do not know class ''%s''.', varargin{2}.className);
                end
            else
                newValue = varargin{2};
            end
            set(counterpartGUI, 'Value', newValue);
            set(varargin{1}, 'String', sprintf('%2.1f', newValue));
        end
        
        if (updateIsGood)
            for k = 1:numel(commandsToExecute)
                eval(commandsToExecute{k});
            end
            stereoGeometer.setState(stereoGeometer.stereoRigState);
            stereoGeometer.redrawScene();
        end
    end
end


function configureInteractiveViewingButtons(stereoGeometer)

    xo = 0.875;
    yo = 0.99;
    width = 0.12;
    height = 0.04;
    
    yo = yo - 0.04;
    % --------- The datacursor mode toggle button (top) --------------
    interactiveDataCursorButton = uicontrol(...
        'Parent', stereoGeometer.window, ...
        'Style', 'togglebutton',...
        'ForegroundColor', [0.1 0.3 0.99], ...
        'String', 'data cursor',...
        'FontSize', 16,...
        'FontWeight', 'b', ...
        'Units', 'normalized',...
        'Position', [xo yo width height]...
        );
    
    yo = yo - 0.04;
    % --------- The interactive 3D view toggle button (top) --------------
    interactive3DViewerButton = uicontrol(...
        'Parent', stereoGeometer.window, ...
        'Style', 'togglebutton',...
        'ForegroundColor', [0.1 0.3 0.99], ...
        'String', 'interactive 3D view',...
        'FontSize', 16,...
        'FontWeight', 'b', ...
        'Units', 'normalized',...
        'Position', [xo yo width height]...
        );
    
    
    yo = yo - 0.04;
    % --------- The interactive zoom toggle button (top-1) --------------
    interactiveZoomButton =  uicontrol(...
        'Parent', stereoGeometer.window,...
        'Style', 'togglebutton',...
        'ForegroundColor', [0.1 0.3 0.99], ...
        'String', 'interactive zoom',...
        'FontSize', 16,...
        'FontWeight', 'b', ...
        'Units', 'normalized',...
        'Position', [xo yo width height]...
       ); 
    
   
    set(interactiveDataCursorButton, 'Callback', {@interactiveDataCursorCallback, stereoGeometer, interactive3DViewerButton, interactiveZoomButton});
    set(interactive3DViewerButton, 'Callback', {@interactive3DViewerCallback, stereoGeometer, interactiveDataCursorButton,  interactiveZoomButton});
    set(interactiveZoomButton,  'Callback', {@interactiveZoomCallback, stereoGeometer,  interactiveDataCursorButton, interactive3DViewerButton});
    
    yo = yo - 0.04;
    animationButton =  uicontrol(...
        'Parent', stereoGeometer.window,...
        'Style', 'togglebutton',...
        'ForegroundColor', [0.1 0.3 0.99], ...
        'String', 'flyby',...
        'FontSize', 16,...
        'FontWeight', 'b', ...
        'Units', 'normalized',...
        'Position', [xo yo width height],...
        'Callback', {@animateViewCallback, stereoGeometer, interactiveDataCursorButton, interactive3DViewerButton, interactiveZoomButton}); 
    
    function animateViewCallback(source, callbackdata, stereoGeometer, counterPartGUI1, counterPartGUI2, counterPartGUI3)    
        persistent t
        if (source.Value == 0)
            stop(t);
            delete(t);
            set(source, 'ForegroundColor', [0.1 0.3 0.99]);
        else
            set(source, 'ForegroundColor', [0.95 0.05 0.05]);
            set(counterPartGUI1, 'ForegroundColor', [0.1 0.3 0.99]);
            set(counterPartGUI2, 'ForegroundColor', [0.1 0.3 0.99]);
            set(counterPartGUI3, 'ForegroundColor', [0.1 0.3 0.99]);
            pause(0.02);
            t = timer('period',1.0);
            set(t,'ExecutionMode','FixedRate','StartDelay',0.01, 'Period', 0.016, 'TimerFcn', {@animationCallback, stereoGeometer});
            start(t);  
        end

        function  animationCallback(hObj, eventdata, stereoGeometer)
            [az, el] = view(stereoGeometer.sceneView);
            az = az + 0.2;
            view(stereoGeometer.sceneView, [az, el]);
        end
    end


    function interactiveZoomCallback(source, callbackdata, stereoGeometer, counterpartGUI1, counterpartGUI2)    
        if (source.Value == 0)
            zoom(stereoGeometer.sceneView, 'off');
            set(source, 'ForegroundColor', [0.1 0.3 0.99]);
        else
            zoom(stereoGeometer.sceneView, 'on');
            set(source, 'ForegroundColor', [0.95 0.05 0.05]);
            set(counterpartGUI1, 'ForegroundColor', [0.1 0.3 0.99]);
            set(counterpartGUI2, 'ForegroundColor', [0.1 0.3 0.99]);
        end
    end


    function interactive3DViewerCallback(source, callbackdata, stereoGeometer, counterpartGUI1, counterpartGUI2)
        [az, el] = view(stereoGeometer.sceneView);
        h = rotate3d(stereoGeometer.sceneView);
        if (source.Value == 0)
            h.Enable = 'off';
            stereoGeometer.viewAngles = [az, el];
            set(source, 'ForegroundColor', [0.1 0.3 0.99]);
        else
            h.Enable = 'on';
            view(stereoGeometer.sceneView, [az el]);
            set(source, 'ForegroundColor', [0.95 0.05 0.05]);
            set(counterpartGUI1, 'ForegroundColor', [0.1 0.3 0.99]);
            set(counterpartGUI2, 'ForegroundColor', [0.1 0.3 0.99]);
        end
    end

    function interactiveDataCursorCallback(source, callbackdata, stereoGeometer, counterpartGUI1, counterpartGUI2)  
        if (source.Value == 0)
            datacursormode(stereoGeometer.window, 'off')
            set(source, 'ForegroundColor', [0.1 0.3 0.99]);
        else
            datacursormode(stereoGeometer.window, 'on')
            set(source, 'ForegroundColor', [0.95 0.05 0.05]);
            set(counterpartGUI1, 'ForegroundColor', [0.1 0.3 0.99]);
            set(counterpartGUI2, 'ForegroundColor', [0.1 0.3 0.99]);
        end
    end

end
    