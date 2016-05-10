% Method for computing the 3D geometry of the scene.
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function generateGeometry(obj)

    obj.XaxisLims = [-120 120];
    obj.YaxisLims = [-130 20];   % depth
    obj.ZaxisLims = [-30 30];
    
    % the virtual 3D point position
    obj.virtual3DPointPosition = [3.0 -30 10];
    
    % Generate the floor plane
    p1 = [obj.XaxisLims(1);    obj.YaxisLims(1);  obj.ZaxisLims(1)];
    p2 = [obj.XaxisLims(end);  obj.YaxisLims(1);  obj.ZaxisLims(1)];
    p3 = [obj.XaxisLims(end);  obj.YaxisLims(end);  obj.ZaxisLims(1)];
    p4 = [obj.XaxisLims(1);    obj.YaxisLims(end);  obj.ZaxisLims(1)];
    obj.floorPlane = obj.generatePlane('floor', p1, p2, p3, p4, '', '', '', '');
    
    % ------------------------ GENERATE THE VERGENCE PLANE -----------------------
    % Vergence plane is at depth (y) = 0;
    % We select its size to be twice that of the monitor
    % Boundary points for vergence plane 
    %            (x)        (depth)   (elevation)
    p1 = [-obj.vergencePlaneWidth/2;  0;  obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  0;  obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  0; -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  0; -obj.vergencePlaneHeight/2];
    obj.vergencePlane = obj.generatePlane('vergence plane', p1, p2, p3, p4, '', '', '', '');
    % move the vergence plane a tiny bit backwards to avoid plotting issues
    obj.vergencePlane = obj.slidePlaneAlongItsNormal(obj.vergencePlane, 0.2);
    
    
    % Generate the virtual stimulus plane (on the vergence plane) 
    p1 = [-obj.virtualStimulusWidth/2;  0;  obj.virtualStimulusHeight/2];
    p2 = [ obj.virtualStimulusWidth/2;  0;  obj.virtualStimulusHeight/2];
    p3 = [ obj.virtualStimulusWidth/2;  0; -obj.virtualStimulusHeight/2];
    p4 = [-obj.virtualStimulusWidth/2;  0; -obj.virtualStimulusHeight/2];
    obj.virtualStimulus = obj.generatePlane('virtual stimulus', p1, p2, p3, p4, '\alpha', '\beta', '\gamma', '\delta');

    % Generate the left monocular virtual stimulus (on the vergence plane)
    p1 = p1 + [-obj.eyeSeparation/2; 0; 0];
    p2 = p2 + [-obj.eyeSeparation/2; 0; 0];
    p3 = p3 + [-obj.eyeSeparation/2; 0; 0];
    p4 = p4 + [-obj.eyeSeparation/2; 0; 0];
    obj.virtualLeftMonocularStimulus = obj.generatePlane('left monocular virtual stimulus', p1, p2, p3, p4, '\phi_L', '\chi_L', '\psi_L', '\omega_L');
    % Generate the right monocular virtual stimulus (on the vergence plane)
    p1 = p1 + [obj.eyeSeparation; 0; 0];
    p2 = p2 + [obj.eyeSeparation; 0; 0];
    p3 = p3 + [obj.eyeSeparation; 0; 0];
    p4 = p4 + [obj.eyeSeparation; 0; 0];
    obj.virtualRightMonocularStimulus = obj.generatePlane('right monocular virtual stimulus', p1, p2, p3, p4, '\phi_R', '\chi_R', '\psi_R', '\omega_R');
    
    % Generate the binocular stimulus (intersection of left and right monocular stimuli).
    p1 = [min(obj.virtualRightMonocularStimulus.boundaryPoints(1,:)); 0; obj.virtualLeftMonocularStimulus.boundaryPoints(3,1)];
    p2 = [max(obj.virtualLeftMonocularStimulus.boundaryPoints(1,:));  0; obj.virtualLeftMonocularStimulus.boundaryPoints(3,2)];
    p3 = [max(obj.virtualLeftMonocularStimulus.boundaryPoints(1,:));  0; obj.virtualLeftMonocularStimulus.boundaryPoints(3,3)];
    p4 = [min(obj.virtualRightMonocularStimulus.boundaryPoints(1,:)); 0; obj.virtualLeftMonocularStimulus.boundaryPoints(3,4)];
    obj.virtualBinocularStimulus = obj.generatePlane('binocular virtual stimulus', p1, p2, p3, p4, '\phi', '\chi', '\psi', '\omega');
    
    % ------------------------ GENERATE THE MIRROR PLANES -----------------------
    p1 = [-obj.mirrorWidth/2;  0;  obj.mirrorHeight/2];
    p2 = [ obj.mirrorWidth/2;  0;  obj.mirrorHeight/2];
    p3 = [ obj.mirrorWidth/2;  0; -obj.mirrorHeight/2];
    p4 = [-obj.mirrorWidth/2;  0; -obj.mirrorHeight/2];
    
    obj.leftMirrorPlane  = obj.generatePlane('left mirror plane', p1, p2, p3, p4, '', '', '', '');
    obj.rightMirrorPlane = obj.generatePlane('right mirror plane', p1, p2, p3, p4, '', '', '', '');
    
    obj.leftMirrorPlane = obj.rotatePlane(obj.leftMirrorPlane, 'zAxis', obj.mirrorRotationLeft);
    obj.leftMirrorPlane = obj.translatePlane(obj.leftMirrorPlane, obj.mirrorPositionLeft);
    
    obj.rightMirrorPlane = obj.rotatePlane(obj.rightMirrorPlane, 'zAxis', obj.mirrorRotationRight);
    obj.rightMirrorPlane = obj.translatePlane(obj.rightMirrorPlane, obj.mirrorPositionRight);
    
    
    % ------------------------ GENERATE THE MONITOR PLANES -----------------------
    p1 = [-obj.monitorWidth/2;  0;  obj.monitorHeight/2];
    p2 = [ obj.monitorWidth/2;  0;  obj.monitorHeight/2];
    p3 = [ obj.monitorWidth/2;  0; -obj.monitorHeight/2];
    p4 = [-obj.monitorWidth/2;  0; -obj.monitorHeight/2];
    
    obj.leftMonitorPlane  = obj.generatePlane('left monitor', p1,p2,p3,p4, '\kappa_L', '\lambda_L', '\mu_L', '\nu_L');
    obj.rightMonitorPlane = obj.generatePlane('right monitor', p1,p2,p3,p4, '\kappa_R', '\lambda_R', '\mu_R', '\nu_R');
    
    obj.leftMonitorPlane = obj.rotatePlane(obj.leftMonitorPlane, 'zAxis', obj.monitorRotationLeft);
    obj.leftMonitorPlane = obj.translatePlane(obj.leftMonitorPlane, obj.monitorPositionLeft);
    
    obj.rightMonitorPlane = obj.rotatePlane(obj.rightMonitorPlane, 'zAxis', obj.monitorRotationRight);
    obj.rightMonitorPlane = obj.translatePlane(obj.rightMonitorPlane, obj.monitorPositionRight);
  
    
    % ------------------------ GENERATE THE RETINAL PLANES  ----------------------
    retinaWidth = 3;
    nodalDistanceToRetina = 1.3;
    retinaHeight = retinaWidth;
    retinalRotationAngle = 90-atan(obj.viewingDistance/(obj.eyeSeparation/2))/pi*180;
    p1 = [-retinaWidth/2;  0;  retinaHeight/2];
    p2 = [ retinaWidth/2;  0;  retinaHeight/2];
    p3 = [ retinaWidth/2;  0; -retinaHeight/2];
    p4 = [-retinaWidth/2;  0; -retinaHeight/2];
    obj.leftRetinalPlane  = obj.generatePlane('left retina', p1,p2,p3,p4, '', '', '', '');
    obj.leftRetinalPlane  = obj.rotatePlane(obj.leftRetinalPlane, 'zAxis', -retinalRotationAngle);
    obj.leftRetinalPlane  = obj.translatePlane(obj.leftRetinalPlane, obj.eyePositionLeft);
    obj.leftRetinalPlane  = obj.slidePlaneAlongItsNormal(obj.leftRetinalPlane, -nodalDistanceToRetina);
    obj.rightRetinalPlane  = obj.generatePlane('right retina', p1,p2,p3,p4, '', '', '', '');
    obj.rightRetinalPlane  = obj.rotatePlane(obj.rightRetinalPlane, 'zAxis', retinalRotationAngle);
    obj.rightRetinalPlane  = obj.translatePlane(obj.rightRetinalPlane, obj.eyePositionRight);
    obj.rightRetinalPlane  = obj.slidePlaneAlongItsNormal(obj.rightRetinalPlane, -nodalDistanceToRetina);
    
    
    % ----- Compute the projection of the virtual stimulus plane onto the left mirror
    nodalPoint = obj.eyePositionLeft;
    pointLabelPostfix = 'L';
    obj.virtualStimulusProjectionOnLeftMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Stimulus Projection On Left Mirror', obj.virtualStimulus, obj.leftMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the project of the virtual left monocular stimulus plane onto the left mirror
    obj.virtualLeftMonocularStimulusProjectionOnLeftMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Left Monocular Stimulus Projection On Left Mirror', obj.virtualLeftMonocularStimulus, obj.leftMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the project of the virtual binocular stimulus plane onto the left mirror
    obj.virtualBinocularStimulusProjectionOnLeftMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Binocular Stimulus Projection On Left Mirror', obj.virtualBinocularStimulus, obj.leftMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
       
       
    % ----- Compute the projection of the virtual stimulus plane onto the right mirror
    nodalPoint = obj.eyePositionRight;
    pointLabelPostfix = 'R';
    obj.virtualStimulusProjectionOnRightMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Stimulus Projection On Right Mirror', obj.virtualStimulus, obj.rightMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the project of the virtual right monocular stimulus plane onto the right mirror
    obj.virtualRightMonocularStimulusProjectionOnRightMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Right Monocular Stimulus Projection On Right Mirror', obj.virtualRightMonocularStimulus, obj.rightMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the project of the virtual binocular stimulus plane onto the right mirror
    obj.virtualBinocularStimulusProjectionOnRightMirror = ...
        obj.generatePlanarProjectionToPlaneViaNodalPoint('Virtual Binocular Stimulus Projection On Right Mirror', obj.virtualBinocularStimulus, obj.rightMirrorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    
    
    % ---- Compute the principal rays
    obj.leftPrincipalRay  = obj.computePrincipalRay(obj.virtualStimulus, obj.leftMirrorPlane, obj.leftMonitorPlane, obj.eyePositionLeft);
    obj.rightPrincipalRay = obj.computePrincipalRay(obj.virtualStimulus, obj.rightMirrorPlane, obj.rightMonitorPlane, obj.eyePositionRight);
    
    
    % ------ Adjust monitor position and rotation depending on mirror rotation ----
    
    % new rotation angles
    deltaRotationAngle        =-(obj.monitorRotationLeft  - obj.leftPrincipalRay.mirrorToMonitorRotationAngle);
    obj.monitorRotationLeft   = obj.monitorRotationLeft  + deltaRotationAngle;
    obj.monitorRotationRight  = obj.monitorRotationRight - deltaRotationAngle;
    
    obj.leftMonitorPlane  = obj.rotatePlane(obj.leftMonitorPlane,  'zAxis',  deltaRotationAngle);
    obj.rightMonitorPlane = obj.rotatePlane(obj.rightMonitorPlane, 'zAxis', -deltaRotationAngle);
    
    radius = sqrt(sum((obj.leftPrincipalRay.mirrorPoint-obj.leftPrincipalRay.virtualStimulusPoint).^2));
    obj.monitorPositionLeft  = obj.leftPrincipalRay.mirrorPoint  + [-radius * cos((90-obj.leftPrincipalRay.mirrorToMonitorRotationAngle)/180*pi);  radius * sin((90-obj.leftPrincipalRay.mirrorToMonitorRotationAngle)/180*pi); 0];
    obj.monitorPositionRight = obj.rightPrincipalRay.mirrorPoint + [radius * cos((90-obj.rightPrincipalRay.mirrorToMonitorRotationAngle)/180*pi); radius * sin((90-obj.rightPrincipalRay.mirrorToMonitorRotationAngle)/180*pi); 0];
    
    deltaTranslationVector = obj.monitorPositionLeft - mean(obj.leftMonitorPlane.boundaryPoints,2);
    obj.leftMonitorPlane = obj.translatePlane(obj.leftMonitorPlane, deltaTranslationVector);
    
    deltaTranslationVector = obj.monitorPositionRight - mean(obj.rightMonitorPlane.boundaryPoints,2);
    obj.rightMonitorPlane = obj.translatePlane(obj.rightMonitorPlane, deltaTranslationVector);
    
    
    % ----- Compute the projection of the left-mirror virtual stimulus projection onto the left monitor plane
    nodalPoint = obj.eyePositionLeft;
    pointLabelPostfix = 'L''';
    obj.virtualStimulusProjectionOnLeftMonitor = ...
        obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Stimulus Projection On Left Monitor', obj.virtualStimulus, obj.leftMirrorPlane, obj.leftMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the projection of the left-mirror left monocular virtual stimulus projection onto the left monitor plane
    obj.virtualLeftMonocularStimulusProjectionOnLeftMonitor = ...
        obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Left Monocular Stimulus Projection On Left Monitor', obj.virtualLeftMonocularStimulus, obj.leftMirrorPlane, obj.leftMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the projection of the binocular virtual stimulus projection onto the left monitor plane
    obj.virtualBinocularStimulusProjectionOnLeftMonitor = ...
        obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Binocular Stimulus Projection On Left Monitor', obj.virtualBinocularStimulus, obj.leftMirrorPlane, obj.leftMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    

    % ----- Compute the projection of the left-mirror virtual stimulus projection onto the left monitor plane
    nodalPoint = obj.eyePositionRight;
    pointLabelPostfix = 'R''';
    obj.virtualStimulusProjectionOnRightMonitor = obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Stimulus Projection On Right Monitor', obj.virtualStimulus, obj.rightMirrorPlane, obj.rightMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
   
    % ----- Compute the projection of the right-mirror right monocular virtual stimulus projection onto the right monitor plane
    obj.virtualRightMonocularStimulusProjectionOnRightMonitor = ...
        obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Right Monocular Stimulus Projection On Right Monitor', obj.virtualRightMonocularStimulus, obj.rightMirrorPlane, obj.rightMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    % ----- Compute the projection of the binocular virtual stimulus projection onto the right monitor plane
    obj.virtualBinocularStimulusProjectionOnRightMonitor = ...
        obj.generatePlanarProjectionToPlaneViaNodalPointAndMirrorDeflection('Virtual Binocular Stimulus Projection On Right Monitor', obj.virtualBinocularStimulus, obj.rightMirrorPlane, obj.rightMonitorPlane, nodalPoint, obj.clipProjectionIfNecessary, pointLabelPostfix);
    
    
    % ---- Re-compute the principal rays, since monitor positions have changed
    obj.leftPrincipalRay  = obj.computePrincipalRay(obj.virtualStimulus, obj.leftMirrorPlane, obj.leftMonitorPlane, obj.eyePositionLeft);
    obj.rightPrincipalRay = obj.computePrincipalRay(obj.virtualStimulus, obj.rightMirrorPlane, obj.rightMonitorPlane, obj.eyePositionRight);
       
    % Generate the maximal aperture plane that will lead to non-rivalrous binocular stimulus
    obj.generateBinocularlyNonRivalrousMaximalAperturePlane();
    
    % Compute the transforms from monitor coords to virtual plane coords
    obj.compute2DTransformFromMonitorCoordsToVirtualPlaneCoords();
    obj.generateMonitorProjectionsToVirtualPlane();
end