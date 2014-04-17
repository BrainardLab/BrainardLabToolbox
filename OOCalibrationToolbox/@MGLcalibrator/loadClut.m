% Method to load the background and target indices of the current LUT.
function loadClut(obj, bgSettings, targetSettings, useBitsPP)

    % Generate LUT
    if (useBitsPP)
        theClut = obj.identityGammaForBitsPP; 
    else 
        theClut = zeros(256,3);
        % Set lower half of LUT to background entry
        theClut(1:128,:) = repmat(bgSettings', [128 1]);
        % Set upper half of LUT to foreground entry
        theClut(129:end,:) = repmat(targetSettings', [128 1]);  
    end

    % Load modified LUT
    if (useBitsPP)  
        mglBitsPlusSetClut(theClut);
    else
        mglSetGammaTable(theClut');
    end
    
end
