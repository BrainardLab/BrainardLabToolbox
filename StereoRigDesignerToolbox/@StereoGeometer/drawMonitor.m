function drawMonitor(obj, monitorPlane)

    if (strcmp(monitorPlane.name, 'left monitor'))
        d = 0.1;
        dd = 3.0;
    elseif (strcmp(monitorPlane.name, 'right monitor'))
        d = 0.1;
        dd = 3.0;
    end
    
    frontPlane = obj.slidePlaneAlongItsNormal(monitorPlane, d);
    backPlane  = obj.slidePlaneAlongItsNormal(monitorPlane, dd);
    
    opacity = 0.8;
    obj.drawConic(frontPlane.boundaryPoints, backPlane.boundaryPoints, [0.1 0.1 0.1], opacity, [0 0 0], '-');
    
    normalVectorDisplay   = struct('length', 0, 'isOn', false);
    boundaryPointsDisplay = struct('size', 20, 'isOn', false);
    obj.drawPlane(backPlane, [0.1 0.1 0.1], opacity, normalVectorDisplay, boundaryPointsDisplay);
end

