% Method to load the background and target indices of the current LUT.
function loadClut(obj, bgSettings, targetSettings, useBitsPP)

    % Generate LUT
    if (useBitsPP)
        theClut = obj.identityGammaForBitsPP; 
    else 
        theClut = zeros(obj.screenInfo.gammaTableLength,3);
        % Set lower half of LUT to background entry
        theClut(1:obj.screenInfo.gammaTableLength/2,:) = repmat(bgSettings', [obj.screenInfo.gammaTableLength/2 1]);
        % Set upper half of LUT to foreground entry
        theClut(obj.screenInfo.gammaTableLength/2+1:end,:) = repmat(targetSettings', [obj.screenInfo.gammaTableLength/2 1]);  
    end
    
    % Load modified LUT
    if (useBitsPP)  
        mglBitsPlusSetClut(theClut);
    else
        mglSetGammaTable(theClut);
    end
    
end
