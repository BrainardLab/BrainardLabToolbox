function recommendedMirrorAngle = computeDefaultMirrorAngleBasedOnEyeSeparation(obj)
    mu = (2 * atan(0.5*obj.eyeSeparation/obj.viewingDistance))/pi*180;
    recommendedMirrorAngle = (90 + mu)/2;
end