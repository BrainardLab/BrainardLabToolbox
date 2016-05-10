% Method for redrawing the entire 3D scene
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function redrawScene(obj)
    
    % Set the outlets
    set(obj.leftMonitorRotationOutlet,  'String', sprintf(' %+2.1f deg (around z-axis)', obj.monitorRotationLeft));
    set(obj.rightMonitorRotationOutlet, 'String', sprintf(' %+2.1f deg (around z-axis)', obj.monitorRotationRight));
    set(obj.leftMonitorPositionOutlet,  'String', sprintf(' [ %+2.1f , %+2.1f, %+2.1f ] cm', obj.monitorPositionLeft(1), obj.monitorPositionLeft(2), obj.monitorPositionLeft(3)));
    set(obj.rightMonitorPositionOutlet, 'String', sprintf(' [ %+2.1f , %+2.1f, %+2.1f ] cm', obj.monitorPositionRight(1), obj.monitorPositionRight(2), obj.monitorPositionRight(3)));
    set(obj.leftMirrorPositionOutlet,   'String', sprintf(' [ %+2.1f , %+2.1f, %+2.1f ] cm', obj.mirrorPositionLeft(1), obj.mirrorPositionLeft(2), obj.mirrorPositionLeft(3)));
    set(obj.rightMirrorPositionOutlet,  'String', sprintf(' [ %+2.1f , %+2.1f, %+2.1f ] cm', obj.mirrorPositionRight(1), obj.mirrorPositionRight(2), obj.mirrorPositionRight(3)));
    aperturePosition = mean(obj.aperturePlane.boundaryPoints,2);
    set(obj.aperturePositionOutlet,     'String', sprintf(' [ %+2.1f , %+2.1f, %+2.1f ] cm', aperturePosition(1), aperturePosition(2), aperturePosition(3)));
    
    apertureWidthInCm = abs(obj.aperturePlane.boundaryPoints(1,1)-obj.aperturePlane.boundaryPoints(1,2));
    apertureHeightInCm = abs(obj.aperturePlane.boundaryPoints(3,3)-obj.aperturePlane.boundaryPoints(3,2));
    if (obj.apertureSizeOutletUseAlternateDisplay)
        % compute aperture in degrees
        apDepth = obj.apertureDepth;
        apertureWidthInDeg  = 2*atan(apertureWidthInCm/(2*(obj.viewingDistance-obj.apertureDepth)))/pi*180;
        apertureHeightInDeg = 2*atan(apertureHeightInCm/(2*(obj.viewingDistance-obj.apertureDepth)))/pi*180;
        set(obj.apertureSizeOutlet,     'String', sprintf(' [ %+2.1f (W) x %+2.1f (H) ] deg', apertureWidthInDeg, apertureHeightInDeg));
    else
        set(obj.apertureSizeOutlet,     'String', sprintf(' [ %+2.1f (W) x %+2.1f (H) ] cm', apertureWidthInCm, apertureHeightInCm));
    end
    
    % Save existing viewing angles and camera view angle (zoom)
    obj.cameraViewAngle = get(obj.sceneView, 'CameraViewAngle');
    [az, el] = view(obj.sceneView);
    obj.viewAngles = [az, el];
    
    
    boxColor = [0.9 0.9 0.85];
    floorColor = 0.7*boxColor;
    xAxisColor = 0.4*[1.0 0.0 0.0];
    yAxisColor = 0.4*[0.0 1.0 0.0];
    zAxisColor = 0.4*[0.0 0.0 1.0];
    
    leftEyeStimColor = 0.8*[1 0.25 0];
    rightEyeStimColor = 0.8*[0 0.25 1];
    binocularStimColor = 0.5*(leftEyeStimColor + rightEyeStimColor);
    
    % Draw the principal axes
    plot3(obj.sceneView, obj.XaxisLims, [0 0], [0 0], 'r-', 'LineWidth', 2.0);
    hold(obj.sceneView, 'on');
    
    plot3(obj.sceneView, [0 0], [0 -obj.viewingDistance], [0 0],  'g-', 'LineWidth', 2.0);
    plot3(obj.sceneView, [0 0], [0 0], obj.ZaxisLims, 'b-', 'LineWidth', 2.0);

    axis(obj.sceneView, 'equal')
    box(obj.sceneView, 'on'); 
    grid(obj.sceneView, 'on');

    ticks = [-200:10:200];
    %ticks = [];
    set(obj.sceneView,  'Color', boxColor, 'XColor', xAxisColor, 'YColor', yAxisColor, 'ZColor', zAxisColor, 'BoxStyle','full', 'Projection', obj.projectionType, ...
                        'XLim', obj.XaxisLims, 'YLim', obj.YaxisLims, 'ZLim', obj. ZaxisLims, 'FontSize', 14, ...
                        'XTick', ticks, 'YTick', ticks, 'ZTick', ticks);
    
    if (strcmp(obj.labelAxes, 'ON'))
        xlabel(obj.sceneView, 'X (horizontal axis)', 'FontSize', 18, 'FontWeight', 'b', 'Color', 'r', 'HorizontalAlignment', 'Center');
        ylabel(obj.sceneView, 'Y (depth axis)', 'FontSize', 18, 'FontWeight', 'b', 'Color', 'g', 'HorizontalAlignment', 'Center');
        zlabel(obj.sceneView, 'Z (vertical axis)', 'FontSize', 18, 'FontWeight', 'b', 'Color', 'b', 'HorizontalAlignment', 'Center');
    end
    
    %hText = text(-10, 0, obj.ZaxisLims(2)+20, obj.titleString, 'FontSize', 20, 'Color', [.1 .3 1]); 
    %set(hText, 'Parent', obj.sceneView);

    
    % ------------ Draw the floor -------------
    normalVectorDisplay   = struct('length', 0, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    obj.drawPlane(obj.floorPlane, floorColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
    
    % ------------ Draw the vergence plane (where the virtual stimulus will be)
    normalVectorDisplay   = struct('length', 0, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    obj.drawPlane(obj.vergencePlane, [0.3 0.3 0.3], 0.45, normalVectorDisplay, boundaryPointsDisplay);
    
    % ------------- Draw the virtual stimulus plane ----------------------
    %    boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
    %    virtualStimulusColor = 0.5*(leftEyeStimColor + rightEyeStimColor);
    %    obj.drawPlane(obj.virtualStimulus, virtualStimulusColor, 0.45, normalVectorDisplay, boundaryPointsDisplay);
    if (~obj.showRealFrustumOnly)
        if (obj.showMonocularPaths)
            % ------------- Draw the virtual left monocular stimulus plane ----------------------
            boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
            virtualStimulusColor = leftEyeStimColor;
            if (obj.showLeftViewFrustum)
                if (strcmp(obj.showEnclosingRoom, 'ON')) || (strcmpi(obj.showEnclosingRoom, 'SEMITRANSPARENT'))
                    obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulus, -0.04), virtualStimulusColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
                else
                    obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualLeftMonocularStimulus, -0.04), virtualStimulusColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
                end
            end
            % ------------- Draw the virtual right monocular stimulus plane ----------------------
            boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
            virtualStimulusColor = rightEyeStimColor;
            if (obj.showRightViewFrustum)
                if (strcmp(obj.showEnclosingRoom, 'ON')) || (strcmpi(obj.showEnclosingRoom, 'SEMITRANSPARENT'))
                    obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulus, -0.08), virtualStimulusColor, 0.45, normalVectorDisplay, boundaryPointsDisplay);
                else
                    obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualRightMonocularStimulus, -0.08), virtualStimulusColor, 0.45, normalVectorDisplay, boundaryPointsDisplay);
                end
            end
        else
            % ------------- Draw the virtual binocular stimulus plane ----------------------
            boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
            virtualStimulusColor = binocularStimColor;
            obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulus, -0.04), virtualStimulusColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
        end
    end
    
    
    % ------------------  Draw the mirror planes --------------------------------
    normalVectorDisplay   = struct('length', 5, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    mirrorColor = [0.8 0.8 0.9];
    obj.drawPlane(obj.leftMirrorPlane, mirrorColor, 0.5, normalVectorDisplay, boundaryPointsDisplay);
    obj.drawPlane(obj.rightMirrorPlane, mirrorColor, 0.5, normalVectorDisplay, boundaryPointsDisplay);
    
    % the point where the two mirrors meet in the middle (this is the mirror assembly position)
    scatter3(obj.sceneView, 0, obj.mirrorDepthPosition, 0, 200, 'filled', 'MarkerFaceColor', [0 0 0])
    
    
    % ------------------- Draw the monitor planes -------------------------
    normalVectorDisplay   = struct('length', -6, 'isOn', true);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    monitorColor = [0.68 0.68 0.68];
    obj.drawPlane(obj.leftMonitorPlane, monitorColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
    obj.drawPlane(obj.rightMonitorPlane, monitorColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);

    % ------------------ Draw the monitor boxes --------------------------------
    obj.drawMonitor(obj.leftMonitorPlane);
    obj.drawMonitor(obj.rightMonitorPlane);
    
    % ----------------- Draw the projections of the virtual stimulus on the two mirrors ------------------
    
%        normalVectorDisplay   = struct('length', 20, 'isOn', false);
%        boundaryPointsDisplay = struct('size', 16, 'isOn', obj.labelBoundaryPoints);
%        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualStimulusProjectionOnLeftMirror, -0.05), leftEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
%        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualStimulusProjectionOnRightMirror,-0.05), rightEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
    if (obj.showMonocularPaths)
        normalVectorDisplay   = struct('length', 20, 'isOn', false);
        boundaryPointsDisplay = struct('size', 16, 'isOn', obj.labelBoundaryPoints);
        if (obj.showLeftViewFrustum)
            obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualLeftMonocularStimulusProjectionOnLeftMirror, -0.05), leftEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
        end
        if (obj.showRightViewFrustum)
            obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualRightMonocularStimulusProjectionOnRightMirror, -0.05), rightEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
        end
    else
        normalVectorDisplay   = struct('length', 20, 'isOn', false);
        boundaryPointsDisplay = struct('size', 16, 'isOn', obj.labelBoundaryPoints);
        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulusProjectionOnLeftMirror, -0.05), leftEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulusProjectionOnRightMirror, -0.05), rightEyeStimColor, 0.8, normalVectorDisplay, boundaryPointsDisplay);
    end
    
    % ----------------- Draw the projections of the virtual stimulus on the  two monitors ------------------------
    
%        normalVectorDisplay   = struct('length', 0, 'isOn', false);
%        boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
%        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualStimulusProjectionOnLeftMonitor, 0.1), leftEyeStimColor, 0.75, normalVectorDisplay, boundaryPointsDisplay);
%        obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualStimulusProjectionOnRightMonitor, 0.1), rightEyeStimColor, 0.75, normalVectorDisplay, boundaryPointsDisplay);
     if (obj.showMonocularPaths)
            normalVectorDisplay   = struct('length', 0, 'isOn', false);
            boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
            if (obj.showLeftViewFrustum)
                obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualLeftMonocularStimulusProjectionOnLeftMonitor, 0.1), leftEyeStimColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
            end
            if (obj.showRightViewFrustum)
                obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualRightMonocularStimulusProjectionOnRightMonitor, 0.1), rightEyeStimColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
            end
        else
            normalVectorDisplay   = struct('length', 0, 'isOn', false);
            boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
            obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulusProjectionOnLeftMonitor, 0.1), leftEyeStimColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
            obj.drawPlane(obj.slidePlaneAlongItsNormal(obj.virtualBinocularStimulusProjectionOnRightMonitor, 0.1), rightEyeStimColor, 1.0, normalVectorDisplay, boundaryPointsDisplay);
     end
        
    % Draw the principal rays
    obj.drawPrincipalRays();
    
    
    % Draw the virtual 3D point and its rays
    if (obj.showVirtual3DPointImage)
       obj.drawVirtual3DPointAndItsRays(); 
    end
    
    % --------------------------- Draw the eyes ---------------------------
    obj.drawFace();

    % --------------------- Draw the left retina --------------------------
    normalVectorDisplay   = struct('length', 10, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    obj.drawPlane(obj.leftRetinalPlane, [0.9 0.8 0.8], 1.0, normalVectorDisplay, boundaryPointsDisplay);
    
    % -------------------- Draw the right retina --------------------------
    normalVectorDisplay   = struct('length', 10, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    obj.drawPlane(obj.rightRetinalPlane, [0.0 0.8 0.9], 1.0, normalVectorDisplay, boundaryPointsDisplay);
    
    
    if (obj.showLeftViewFrustum)
        if (obj.strokeFrusta)
            edgeColor = 1.1*leftEyeStimColor;
        else
            edgeColor = 'none';
        end
        if (obj.fillFrusta)
            fillColor = leftEyeStimColor;
        else
            fillColor = 'none';
        end
        % ------------------- Draw left path frustum -------------------------
%            obj.drawConic(obj.virtualStimulus.boundaryPoints, obj.virtualStimulusProjectionOnLeftMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--');
%            obj.drawConic(obj.virtualStimulusProjectionOnLeftMirror.boundaryPoints, obj.virtualStimulusProjectionOnLeftMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
%            obj.drawConic(obj.virtualStimulusProjectionOnLeftMirror.boundaryPoints, repmat(obj.eyePositionLeft, [1 4]),  fillColor, 0.2, edgeColor, '-' );
        if (obj.showMonocularPaths)
            if (obj.showLeftViewFrustum)
                if (~obj.showRealFrustumOnly)
                    obj.drawConic(obj.virtualLeftMonocularStimulus.boundaryPoints*0.99, obj.virtualLeftMonocularStimulusProjectionOnLeftMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--');
                end
                obj.drawConic(obj.virtualLeftMonocularStimulusProjectionOnLeftMirror.boundaryPoints, obj.virtualLeftMonocularStimulusProjectionOnLeftMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
                obj.drawConic(obj.virtualLeftMonocularStimulusProjectionOnLeftMirror.boundaryPoints, repmat(obj.eyePositionLeft, [1 4]),  fillColor, 0.2, edgeColor, '-' );
            end
        else
            if (~obj.showRealFrustumOnly)
                obj.drawConic(obj.virtualBinocularStimulus.boundaryPoints*0.99, obj.virtualBinocularStimulusProjectionOnLeftMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--');
            end
                obj.drawConic(obj.virtualBinocularStimulusProjectionOnLeftMirror.boundaryPoints, obj.virtualBinocularStimulusProjectionOnLeftMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
            obj.drawConic(obj.virtualBinocularStimulusProjectionOnLeftMirror.boundaryPoints, repmat(obj.eyePositionLeft, [1 4]),  fillColor, 0.2, edgeColor, '-' );
        end
    end
    
    if (obj.showRightViewFrustum)
        if (obj.strokeFrusta)
            edgeColor = 1.1*rightEyeStimColor;
        else
            edgeColor = 'none';
        end
        if (obj.fillFrusta)
            fillColor = rightEyeStimColor;
        else
            fillColor = 'none';
        end
        % -------------------- Draw right path frustum -----------------------
        
%            obj.drawConic(obj.virtualStimulus.boundaryPoints, obj.virtualStimulusProjectionOnRightMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--' );
%            obj.drawConic(obj.virtualStimulusProjectionOnRightMirror.boundaryPoints, obj.virtualStimulusProjectionOnRightMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
%            obj.drawConic(obj.virtualStimulusProjectionOnRightMirror.boundaryPoints, repmat(obj.eyePositionRight, [1 4]),  fillColor, 0.2, edgeColor, '-' );
        if (obj.showMonocularPaths)
            if (obj.showRightViewFrustum)
                if (~obj.showRealFrustumOnly)
                    obj.drawConic(obj.virtualRightMonocularStimulus.boundaryPoints*0.99, obj.virtualRightMonocularStimulusProjectionOnRightMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--' );
                end
                obj.drawConic(obj.virtualRightMonocularStimulusProjectionOnRightMirror.boundaryPoints, obj.virtualRightMonocularStimulusProjectionOnRightMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
                obj.drawConic(obj.virtualRightMonocularStimulusProjectionOnRightMirror.boundaryPoints, repmat(obj.eyePositionRight, [1 4]),  fillColor, 0.2, edgeColor, '-' );
            end
        else
            if (~obj.showRealFrustumOnly)
                obj.drawConic(obj.virtualBinocularStimulus.boundaryPoints*0.99, obj.virtualBinocularStimulusProjectionOnRightMirror.boundaryPoints, fillColor, 0.4, edgeColor, '--' );
            end
            obj.drawConic(obj.virtualBinocularStimulusProjectionOnRightMirror.boundaryPoints, obj.virtualBinocularStimulusProjectionOnRightMonitor.boundaryPoints, fillColor, 0.2, edgeColor, '-');
            obj.drawConic(obj.virtualBinocularStimulusProjectionOnRightMirror.boundaryPoints, repmat(obj.eyePositionRight, [1 4]),  fillColor, 0.2, edgeColor, '-' );
        end
    end

    
    if (obj.viewMonitorProjectionsOnVirtualStimulusPlane)
        % ------- Draw the left and right monitor images on the virtual plane
        normalVectorDisplay   = struct('length', 0, 'isOn', false);
        boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
        leftMonitorOutlineColor = [1.0 1.0 0.0];
        rightMonitorOutlineColor = [0.0 1.0 1.0];
        obj.drawPlane(obj.leftMonitorImageOnVirtualPlane, leftMonitorOutlineColor, 0.75, normalVectorDisplay, boundaryPointsDisplay, 'outline');
        obj.drawPlane(obj.rightMonitorImageOnVirtualPlane, rightMonitorOutlineColor, 0.75, normalVectorDisplay, boundaryPointsDisplay, 'outline');

        % ------- Outline the left and right monitor planes
        obj.drawPlane(obj.leftMonitorPlane, leftMonitorOutlineColor, 0.75, normalVectorDisplay, boundaryPointsDisplay, 'outline');
        obj.drawPlane(obj.rightMonitorPlane, rightMonitorOutlineColor, 0.75, normalVectorDisplay, boundaryPointsDisplay, 'outline');
    end
    
    if (strcmp(obj.showEnclosingRoom, 'ON')) || (strcmpi(obj.showEnclosingRoom, 'SEMITRANSPARENT'))
        enclosingRoomColor = 0.2*[1 1 1];
        if (strcmp(obj.showEnclosingRoom, 'ON'))
            enclosingRoomOpacity = 1.0;
            outline = 'fill+outline';
        else
            enclosingRoomOpacity = 0.5;
            outline = 'fill+outline';
        end
        normalVectorDisplay   = struct('length', 0, 'isOn', false);
        boundaryPointsDisplay = struct('size', 20, 'isOn', false);
        obj.drawPlane(obj.enclosingRoom('top half'),    enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, 'no outline');
        obj.drawPlane(obj.enclosingRoom('bottom half'), enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, 'no outline');
        obj.drawPlane(obj.enclosingRoom('left half'),   enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, 'no outline');
        obj.drawPlane(obj.enclosingRoom('right half'),  enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, 'no outline');
        obj.drawPlane(obj.enclosingRoom('floor'),       enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, outline);
        obj.drawPlane(obj.enclosingRoom('ceiling'),     enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, outline);
        obj.drawPlane(obj.enclosingRoom('left wall'),   enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, outline);
        obj.drawPlane(obj.enclosingRoom('right wall'),  enclosingRoomColor, enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay, outline);
        obj.drawPlane(obj.enclosingRoom('back wall'),   enclosingRoomColor,  enclosingRoomOpacity, normalVectorDisplay, boundaryPointsDisplay,  outline);
    end
    
    % draw the aperture 
    if (obj.showAperturePlane)
        normalVectorDisplay   = struct('length', 0, 'isOn', false);
        boundaryPointsDisplay = struct('size', 20, 'isOn', obj.labelBoundaryPoints);
        obj.drawPlane(obj.aperturePlane, [0.9 0.9 0.9], 0.5, normalVectorDisplay, boundaryPointsDisplay, 'outline');
    end
    
    % ------------------- FINALIZE------------------------------
    % apply previous viewing angles
    view(obj.sceneView, obj.viewAngles);
    set(obj.sceneView, 'CameraViewAngle', obj.cameraViewAngle);
    hold(obj.sceneView, 'off');
    
    %drawnow;
end
