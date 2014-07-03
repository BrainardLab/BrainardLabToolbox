function [Xdistorted, Ydistorted] = EstimateProjectiveTransform(Xnominal, Ynominal, sampledXnominal, sampledYnominal, sampledXdistorted, sampledYdistorted)
%    
    % Estimate optimal projective transform based on sampled distorted pairs of points
    optimalMappingTransform = cp2tform([sampledXdistorted, sampledYdistorted], [sampledXnominal, sampledYnominal], 'projective');
    
    XnominalTransposed = Xnominal';
    YnominalTransposed = Ynominal';
    
    % Use the estimate optimal mapping transform to compute the entire grid
    [Xserialized, Yserialized] = tforminv(optimalMappingTransform, XnominalTransposed(:), YnominalTransposed(:));
     
    % Repackage in 2D array of the input format
    Xdistorted = Xnominal*0;
    Ydistorted = Ynominal*0;
    p = 0;
    for row = 1:size(Xnominal,1)
        for col = 1:size(Xnominal,2)
            p = p + 1;
            Xdistorted(row,col) = Xserialized(p);
            Ydistorted(row,col) = Yserialized(p);
        end
    end
end