function obj = computeReusableQuantities(obj)
    
    % Load CIE '31 color matching functions
    load T_xyz1931
    obj.T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,obj.rawData.S);
    
    % Compute spectral axis
    S = obj.cal.rawData.S;
    obj.spectralAxis = SToWls(S);
    
    obj.cal = SetSensorColorSpace(obj.cal, obj.T_xyz, S);
end

