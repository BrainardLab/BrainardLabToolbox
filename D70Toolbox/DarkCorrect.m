function correctedImage = DarkCorrect(CamCal,info,rawImage)
% rawImage = DarkCorrect(CamCal,info,rawImage)
%
% Dark correct an RGB image, given camera calibration and image info structures.
% Sets any negative values to 0.
%
% 11/12/10  dhb  Made a function

correctedImage = rawImage;
exindex = CamCal.darkTable(:,1)==info.exposure;
for i=1:3
    correctedImage(:,:,i) = rawImage(:,:,i) - CamCal.darkTable(exindex,i);
end
correctedImage(correctedImage < 0) = 0;