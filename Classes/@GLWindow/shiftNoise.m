function glwObj = shiftNoise(glwObj, noiseName, shiftValues)

global g_GLWNoiseData;

% Locate the noise object in the queue and get the index to the noise data.
objectIndex = findObjectIndex(glwObj.private.objects, noiseName);
nIndex = glwObj.private.objects{objectIndex}.noiseIndex;

d = g_GLWNoiseData{nIndex};
d(1,:) = d(1,:) + shiftValues(1);
d(2,:) = d(2,:) + shiftValues(2);
g_GLWNoiseData{index} = d;

