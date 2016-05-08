% Method to compute the maximal aperture that leads to
% non rivalrous binocular stimulus (depending on the set aperture depth)
function generateBinocularlyNonRivalrousMaximalAperturePlane(obj)

    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth; -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth; -obj.vergencePlaneHeight/2];
    
    frontWallPlane = obj.generatePlane('front wall', p1, p2, p3, p4, '', '', '', '');
    intersectionPoints = zeros(3,4);
    for k = 1:size(intersectionPoints,2)
        linePoint1 = obj.virtualBinocularStimulus.boundaryPoints(:,k);
        % check sign of x-coord, to choose the contralateral eye position
        if (linePoint1(1) < 0)
            linePoint2 = obj.eyePositionRight;
        else
            linePoint2 = obj.eyePositionLeft;
        end
        intersectionPoints(:,k) = obj.computeIntersectionBetweenLineAndPlane(linePoint1, linePoint2, frontWallPlane);
    end
    
    obj.aperturePlane = obj.generatePlane('aperture', ...
                        intersectionPoints(:,1), ...
                        intersectionPoints(:,2), ...
                        intersectionPoints(:,3), ...
                        intersectionPoints(:,4), ...
                        '', '', '', '');
    
    % Generate walls of enclosing room                
    obj.enclosingRoom = containers.Map();
    
    apertureLeftXcoord   = obj.aperturePlane.boundaryPoints(1,1);
    apertureRightXcoord  = obj.aperturePlane.boundaryPoints(1,2);
    apertureTopYcoord    = obj.aperturePlane.boundaryPoints(3,1);
    apertureBottomYcoord = obj.aperturePlane.boundaryPoints(3,3);
                    
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth; apertureTopYcoord];
    p4 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth; apertureTopYcoord];
    obj.enclosingRoom('top half') = obj.generatePlane('top half', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureBottomYcoord ];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureBottomYcoord];
    p3 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth; -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth; -obj.vergencePlaneHeight/2];
    obj.enclosingRoom('bottom half') = obj.generatePlane('bottom half', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureTopYcoord];
    p2 = [ apertureLeftXcoord;        -obj.apertureDepth;  apertureTopYcoord];
    p3 = [ apertureLeftXcoord;        -obj.apertureDepth;  apertureBottomYcoord];
    p4 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureBottomYcoord];
    obj.enclosingRoom('left half') = obj.generatePlane('left half', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [ apertureRightXcoord;       -obj.apertureDepth;  apertureTopYcoord];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureTopYcoord];
    p3 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  apertureBottomYcoord];
    p4 = [ apertureRightXcoord;       -obj.apertureDepth;  apertureBottomYcoord];
    obj.enclosingRoom('right half') = obj.generatePlane('right half', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  -obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  -obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  0;                   -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  0;                   -obj.vergencePlaneHeight/2];
    obj.enclosingRoom('floor') = obj.generatePlane('floor', p1, p2, p3, p4, '', '', '', '');
   
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;   obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;   obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  0;                    obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  0;                    obj.vergencePlaneHeight/2];
    obj.enclosingRoom('ceiling') = obj.generatePlane('ceiling', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;   obj.vergencePlaneHeight/2];
    p2 = [-obj.vergencePlaneWidth/2;  -obj.apertureDepth;  -obj.vergencePlaneHeight/2];
    p3 = [-obj.vergencePlaneWidth/2;  0;                   -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  0;                    obj.vergencePlaneHeight/2];
    obj.enclosingRoom('left wall') = obj.generatePlane('left wall', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;   obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  -obj.apertureDepth;  -obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  0;                   -obj.vergencePlaneHeight/2];
    p4 = [ obj.vergencePlaneWidth/2;  0;                    obj.vergencePlaneHeight/2];
    obj.enclosingRoom('right wall') = obj.generatePlane('right wall', p1, p2, p3, p4, '', '', '', '');
    
    p1 = [-obj.vergencePlaneWidth/2;  0.1;  obj.vergencePlaneHeight/2];
    p2 = [ obj.vergencePlaneWidth/2;  0.1;  obj.vergencePlaneHeight/2];
    p3 = [ obj.vergencePlaneWidth/2;  0.1; -obj.vergencePlaneHeight/2];
    p4 = [-obj.vergencePlaneWidth/2;  0.1; -obj.vergencePlaneHeight/2];
    obj.enclosingRoom('back wall') = obj.generatePlane('back wall', p1, p2, p3, p4, '', '', '', '');
    
end