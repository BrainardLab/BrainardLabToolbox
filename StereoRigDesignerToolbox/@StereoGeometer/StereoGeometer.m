% Class with methods for eazy geometric 3D plotting
% 
% 10/13/2015  npc Wrote it.
%

classdef StereoGeometer < handle
    
    properties
        
        % just a copy of the rig state struct
        % this is used purely for the gui callbacks
        % to save their updated property values
        stereoRigState
        
        % Viewing options
        labelBoundaryPoints = false;
        
        labelAxes = 'OFF';
        
        showVirtual3DPointImage = true;
        showEnclosingRoom = 'Semitransparent';
        showAperturePlane = true;
        
        showMonocularPaths = true;
        showLeftViewFrustum = true;
        showRightViewFrustum = true;
        showRealFrustumOnly = false;
        strokeFrusta = true;
        fillFrusta = false;
        
        viewMonitorProjectionsOnVirtualStimulusPlane = false;
        clipProjectionIfNecessary = true;
        
        viewAngles = [57.2 29.2];
        cameraViewAngle = 5.8;  % camera angle controls the zoom, the wider the angle, the smaller the components
        
        % the outlet modifier toggles
        leftMonitorPositionOutletUseAlternateDisplay = false;
        leftMonitorRotationOutletUseAlternateDisplay = false;
        rightMonitorPositionOutletUseAlternateDisplay = false;
        rightMonitorRotationOutletUseAlternateDisplay = false;
        leftMirrorPositionOutletUseAlternateDisplay = false;
        rightMirrorPositionOutletUseAlternateDisplay = false;
        aperturePositionOutletUseAlternateDisplay = false;
        apertureSizeOutletUseAlternateDisplay = false;
       
    end
    
    properties (SetAccess = private)
        
        % primary properties
        viewingDistance
        eyeSeparation
        
        virtual3DPointPosition
        vergencePlaneWidth
        vergencePlaneHeight
        
        virtualStimulusWidth
        virtualStimulusHeight
        apertureDepth
        
        mirrorWidth 
        mirrorHeight
        mirrorDistanceFromEyeNodalPoint 
        mirrorOffset
        mirrorRotationLeft 
        mirrorRotationRight
    
        monitorName  
        monitorDiagonalSize 
        monitorPixelsHeight 
        monitorPixelsWidth 
        monitorDepthPosition 
        monitorHorizPosition 
        monitorRotationLeft 
        monitorRotationRight 
    
        % dependent (on primary) properties
        eyePositionLeft
        eyePositionRight
        
        mirrorDepthPosition
        mirrorPositionLeft
        mirrorPositionRight
        
        monitorWidth
        monitorHeight
        monitorPositionLeft
        monitorPositionRight
        
        % a container with 'left', 'right' keys
        monitorCoordsToVirtualPlaneCoordsTransform
        
        defaultViewAngles = [57.2 29.2];
    end
    
    properties (SetAccess = private)
        window
        sceneView
        projectionType
        titleString
    end
    
    properties (Access = private)

        XaxisLims
        YaxisLims
        ZaxisLims
        
       % Geometrical elements
       floorPlane
       
       vergencePlane
       aperturePlane
       enclosingRoom
       
       virtualStimulus
       virtualLeftMonocularStimulus
       virtualRightMonocularStimulus
       virtualBinocularStimulus
       
       leftMirrorPlane
       rightMirrorPlane
       
       leftMonitorPlane
       rightMonitorPlane
       
       leftRetinalPlane
       rightRetinalPlane
       
       virtualStimulusProjectionOnLeftMirror
       virtualStimulusProjectionOnRightMirror
       virtualStimulusProjectionOnLeftMonitor
       virtualStimulusProjectionOnRightMonitor
       
       virtualLeftMonocularStimulusProjectionOnLeftMirror
       virtualRightMonocularStimulusProjectionOnRightMirror
       
       virtualLeftMonocularStimulusProjectionOnLeftMonitor
       virtualRightMonocularStimulusProjectionOnRightMonitor
       
       virtualBinocularStimulusProjectionOnLeftMirror
       virtualBinocularStimulusProjectionOnRightMirror
       virtualBinocularStimulusProjectionOnLeftMonitor
       virtualBinocularStimulusProjectionOnRightMonitor
       
       leftMonitorImageOnVirtualPlane
       rightMonitorImageOnVirtualPlane
       
       leftPrincipalRay
       rightPrincipalRay
 
       % the outlets
       leftMonitorPositionOutlet
       leftMonitorRotationOutlet
       rightMonitorPositionOutlet
       rightMonitorRotationOutlet
       leftMirrorPositionOutlet
       rightMirrorPositionOutlet
       aperturePositionOutlet
       apertureSizeOutlet
    end
    
    
    
    methods 
        function obj = StereoGeometer(figNo, windowSize, projectionType, titleString)
            
            obj.projectionType = projectionType;
            obj.titleString = titleString;
            obj.window     = figure(figNo);
            set(obj.window, 'Position', [300 1000 windowSize(1) windowSize(2)], 'Color', [0.7 0.7 0.7], ...
                'NumberTitle', 'off', 'Name', 'Stereo Rig Designer by N.P. Cottaris', ...
                'MenuBar','None', 'Visible','Off');
            clf;
            
            obj.sceneView = axes('Parent', obj.window,...
                    'Units', 'normalized',...
                    'Position', [0.03 0.15 0.98 0.6]);
                
            %view(obj.sceneView, obj.viewAngles);
            set(obj.sceneView, 'CameraViewAngle', obj.cameraViewAngle);
        end
        
        % Method to set the state of all components
        setState(obj, state);
        
        
        % Method to compute the default mirror angles based on eye separation
        newValue = computeDefaultMirrorAngleBasedOnEyeSeparation(obj);
        
        % Method to compute the maximal aperture that leads to
        % non rivalrous binocular stimulus (depending on the set aperture depth)
        generateBinocularlyNonRivalrousMaximalAperturePlane(obj);
        
        % Method to update the dependent properties
        computeDependentProperties(obj);
        
        % Method to update the scene
        redrawScene(obj)
        
        % Method to draw a plane
        drawPlane(obj,plane, color, opacity, normalVectorDisplay, boundaryPointsDisplay, varargin)
        
        % Method to draw the observer's face
        drawFace(obj)
        
        % Method to draw the left,right principal vergence rays
        drawPrincipalRays(obj)

        % draw the frustrum between two planar projections
        drawConic(obj, planeApoints, planeBpoints, color, opacity, edgeColor, edgeStyle)
        
        % draw the virtual 3Dpoint and its rays to the eyes/monitors
        drawVirtual3DPointAndItsRays(obj);
        
        % draw a monitor box behind the monitor plane
        drawMonitor(obj, monitorPlane)
        
        % Set the viewing angle and zoom factor
        setView(obj, mode);
        
        
        function exportFigToPDF(obj, pdfFileName, dpi)
            NicePlot.exportFigToPDF(pdfFileName, obj.window, dpi);
        end
        
        function exportFigToPNG(obj, pngFileName, dpi)
            NicePlot.exportFigToPNG(pngFileName, obj.window, dpi);
        end
    end
    
    
    methods (Access = private)
        generateGeometry(obj);
        compute2DTransformFromMonitorCoordsToVirtualPlaneCoords(obj);
        generateMonitorProjectionsToVirtualPlane(obj);
    end
    
    
    
    
    methods (Static = true)
        
        function normal = computeNormal(p1, p2, p3)
            normal = cross(p1-p2, p1-p3);
        end
        
        function angle = computeAngleBetweenVectors(v,u)
           cosAngle = dot(u,v)/(norm(u)*norm(v));
           angle = acos(cosAngle)/pi*180;
        end
        
        function coeff = computePlaneCoefficients(p1, p2, p3)
            % Compute coefficients fore plane AX+BY+CZ+D = 0
            normal = StereoGeometer.computeNormal(p1, p2, p3);
            coeff.A = normal(1); 
            coeff.B = normal(2); 
            coeff.C = normal(3);
            coeff.D = -dot(normal,p1);
        end

        function plane = generatePlane(planeName, p1, p2, p3, p4, p1Label, p2Label, p3Label, p4Label)
            plane = struct(...
                'name', planeName, ...
                'boundaryPoints', [p1 p2 p3 p4], ...
                'coeff',  StereoGeometer.computePlaneCoefficients(p1, p2, p3), ...
                'normal', StereoGeometer.computeNormal(p1, p2, p3) ...
            );
            plane.boundaryLabels = {p1Label, p2Label, p3Label, p4Label};
        end

        
        function rotatedPlane = rotatePlane(plane, rotationAxis, rotationAngle)

            switch rotationAxis
                case 'xAxis'
                    R = makehgtform('xrotate', rotationAngle/180*pi);
               case 'yAxis'
                    R = makehgtform('yrotate', rotationAngle/180*pi);
                case 'zAxis'
                    R = makehgtform('zrotate', rotationAngle/180*pi);
            end

            % Only use the 3x3 submatrix
            R = R(1:3,1:3);

            center = repmat((mean(plane.boundaryPoints,2)), 1, size(plane.boundaryPoints,2));
            rotatedPlane.boundaryPoints = (R*(plane.boundaryPoints-center) + center);
            rotatedPlane.boundaryLabels = plane.boundaryLabels;
            rotatedPlane.coeff  = StereoGeometer.computePlaneCoefficients(rotatedPlane.boundaryPoints(:,1), rotatedPlane.boundaryPoints(:,2), rotatedPlane.boundaryPoints(:,3));
            rotatedPlane.normal = StereoGeometer.computeNormal(rotatedPlane.boundaryPoints(:,1), rotatedPlane.boundaryPoints(:,2), rotatedPlane.boundaryPoints(:,3));
            rotatedPlane.name = plane.name;
        end

        
        function translatedPlane = translatePlane(plane, translationVector)
            translatedPlane.boundaryPoints = bsxfun(@plus, plane.boundaryPoints, translationVector);
            translatedPlane.boundaryLabels = plane.boundaryLabels;
            translatedPlane.coeff  = StereoGeometer.computePlaneCoefficients(translatedPlane.boundaryPoints(:,1), translatedPlane.boundaryPoints(:,2), translatedPlane.boundaryPoints(:,3));
            translatedPlane.normal = StereoGeometer.computeNormal(translatedPlane.boundaryPoints(:,1), translatedPlane.boundaryPoints(:,2), translatedPlane.boundaryPoints(:,3));
            translatedPlane.name = plane.name;
        end


        function translatedPlane = slidePlaneAlongItsNormal(plane, translationFactor)
            translatedPlane.boundaryPoints = bsxfun(@plus, plane.boundaryPoints, translationFactor * plane.normal /norm(plane.normal));
            translatedPlane.boundaryLabels = plane.boundaryLabels;
            translatedPlane.coeff  = StereoGeometer.computePlaneCoefficients(translatedPlane.boundaryPoints(:,1), translatedPlane.boundaryPoints(:,2), translatedPlane.boundaryPoints(:,3));
            translatedPlane.normal = StereoGeometer.computeNormal(translatedPlane.boundaryPoints(:,1), translatedPlane.boundaryPoints(:,2), translatedPlane.boundaryPoints(:,3));
            translatedPlane.name = plane.name;
        end
        
        
        function projectionPlane = generatePlanarProjectionToPlaneViaNodalPoint(destinationPlaneName, sourcePlane, destinationPlane, nodalPoint, clipProjectionIfNecessary, pointLabelPostfix)
            
            linePoint1 = nodalPoint;
            p = zeros(size(sourcePlane.boundaryPoints));
            
            for sourcePlanePointIndex = 1:size(sourcePlane.boundaryPoints,2)  
                linePoint2 = sourcePlane.boundaryPoints(:,sourcePlanePointIndex);
                p(:,sourcePlanePointIndex) = StereoGeometer.computeIntersectionBetweenLineAndPlane(linePoint1, linePoint2, destinationPlane);
                pLabel{sourcePlanePointIndex} = sprintf('%s_%s', sourcePlane.boundaryLabels{sourcePlanePointIndex}, pointLabelPostfix);
            end
            
            projectionPlane = StereoGeometer.generatePlane(destinationPlaneName, p(:,1), p(:,2), p(:,3), p(:,4), pLabel{1}, pLabel{2}, pLabel{3}, pLabel{4});
        end
        
        
        
        function projectionPlane = generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection(finalDestinationPlaneName, sourcePlane, mirrorPlane, finalDestinationPlane, nodalPoint, clipProjectionIfNecessary, pointLabelPostfix)
            
            linePoint1 = nodalPoint;
            p = zeros(size(sourcePlane.boundaryPoints));
            m = zeros(size(sourcePlane.boundaryPoints));
            
            mirrorPlane.normal = mirrorPlane.normal / norm(mirrorPlane.normal);
            
            for sourcePlanePointIndex = 1:size(sourcePlane.boundaryPoints,2)   
                linePoint2 = sourcePlane.boundaryPoints(:,sourcePlanePointIndex);
                
                % find corresponding mirror point
                m(:,sourcePlanePointIndex) = StereoGeometer.computeIntersectionBetweenLineAndPlane(linePoint1, linePoint2, mirrorPlane);
                
                incidentVector = linePoint1-linePoint2;
                %incidentVectorAngle = StereoGeometer.computeAngleBetweenVectors(incidentVector, mirrorPlane.normal)
                
                reflectionVector = incidentVector - 2 * dot(incidentVector, mirrorPlane.normal) * mirrorPlane.normal;
                %reflectiontVectorAngle = StereoGeometer.computeAngleBetweenVectors(reflectionVector, mirrorPlane.normal)
                
                linePoint3 = m(:,sourcePlanePointIndex) + reflectionVector;
                p(:,sourcePlanePointIndex) = StereoGeometer.computeIntersectionBetweenLineAndPlane(m(:,sourcePlanePointIndex), linePoint3, finalDestinationPlane);
                pLabel{sourcePlanePointIndex} = sprintf('%s_%s', sourcePlane.boundaryLabels{sourcePlanePointIndex}, pointLabelPostfix);
            end
        
            projectionPlane = StereoGeometer.generatePlane(finalDestinationPlaneName, p(:,1), p(:,2), p(:,3), p(:,4), pLabel{1}, pLabel{2}, pLabel{3}, pLabel{4});
        end
        
        function principalRay = computePrincipalRay(virtualStimulus, mirrorPlane, monitorPlane, nodalPoint)
            centerOfVirtualStimulus = mean(virtualStimulus.boundaryPoints, 2);
            incidentVector   = nodalPoint - centerOfVirtualStimulus;
            mirrorPlane.normal = mirrorPlane.normal / norm(mirrorPlane.normal);
            reflectionVector = incidentVector - 2 * dot(incidentVector, mirrorPlane.normal) * mirrorPlane.normal;
            correspondingMirrorPoint  = StereoGeometer.computeIntersectionBetweenLineAndPlane(nodalPoint, centerOfVirtualStimulus, mirrorPlane);
            correspondingMonitorPoint = StereoGeometer.computeIntersectionBetweenLineAndPlane(correspondingMirrorPoint, correspondingMirrorPoint + reflectionVector, monitorPlane);
            mirrorToMonitorRotationAngle = StereoGeometer.computeAngleBetweenVectors(reflectionVector, [0 -1 0]);
            
            principalRay = struct(...
                'virtualStimulusPoint', centerOfVirtualStimulus, ...
                'mirrorPoint',   correspondingMirrorPoint, ...
                'monitorPoint',  correspondingMonitorPoint, ...
                'nodalPoint', nodalPoint, ...
                'mirrorToMonitorRotationAngle', mirrorToMonitorRotationAngle);
        end
        
        
        function projectionPoint = computeIntersectionBetweenLineAndPlane(linePoint1, linePoint2, plane)
            N = plane.normal;
            projectionPoint = linePoint1 + (dot(N, plane.boundaryPoints(:,1) - linePoint1) / dot(N, linePoint2 - linePoint1)) * (linePoint2 - linePoint1);
        end
        
    end
end


