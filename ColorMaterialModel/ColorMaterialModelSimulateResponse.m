function response = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, colorMatchColorCoord, materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma)
% function response = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, colorMatchColorCoord, materialMatchColorCoord,colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma)
%
% We simulate responses following the same experimental design as we have
% in the actual experiment. We assume that on each trial, the target and
% each competitor is represented as a draw in 2-dimensional
% perceptual space (where one dimension is color and another is material).
% this is a noisy draw centered arond the true (C,M) mean position. 
% On each trial subject select the competitor that is closer to the target 
% i.e., the distance between the target (current draw) and that competitor
% (current draw) is smaller than the target and the other competitor. 

%   Inputs:
%       targetColorCoord  - target position on color dimension (should be fixed to 0).
%       targetMaterialCoord  - target position on material dimension (should be fixed to 0).
%
%       colorMatchColorCoord - inferred position on the color dimension for the first competitor in the pair
%       materialMatchColorCoord - inferred position on the material dimension for the first competitor in the pair
%       colorMatchMaterialCoord - inferred position on the color dimension for the second competitor in the pair
%        materialMatchMaterialCoord - inferred position on the material dimension for the second competitor in the pair
%       w - weight for color dimension.
%       sigma - noise around the target position (we assume it is equal to 1 and the same
%               for both color and material dimenesions).
%   Output: 
%       response - response, given the input parameter. 1 if the color
%       match is chosen. 0 if material match is chosen. 

% Nov 2016 ar      Wrote it
% Nov 2016 ar, dhb Edits and comments. 

% Simulate a trial given target and a competitor pair.

%% Prevent pathological values of w
if (w == 0)
    w = 0.0001;
elseif (w == 1)
    w = 0.9999;
end

% Parameters
DO_APPROX = false;

% Note that we're not explicitly adding noise to the target. 
% Rather, we add noise to competitor positions and we assume that this
% noise aggregates the target and competitor noise. 
colorMatchColorCoord = colorMatchColorCoord + normrnd(0,sigma); 
materialMatchColorCoord = materialMatchColorCoord + normrnd(0,sigma); 
colorMatchMaterialCoord = colorMatchMaterialCoord + normrnd(0,sigma); 
materialMatchMaterialCoord = materialMatchMaterialCoord + normrnd(0,sigma); 

% In the approximation case, we apply the weights to the distances rather
% than to the coordinates.  This is not really want we want, but is where
% we started.  Also, we know how to do this on analytically, so being able
% to run it was useful for some early checks.
if (DO_APPROX) 
    % Compute distances
    colorMatchColorCoordDiff = (colorMatchColorCoord-targetColorCoord); 
    materialMatchColorCoordDiff = (materialMatchColorCoord-targetColorCoord); 
    colorMatchMaterialCoordDiff = (colorMatchMaterialCoord-targetMaterialCoord);
    materialMatchMaterialCoordDiff = (materialMatchMaterialCoord-targetMaterialCoord);
      
    % Compute squared distance and compare
    colorMatchDist2 = colorMatchColorCoordDiff^2 + colorMatchMaterialCoordDiff^2;
    materialMatchDist2 = materialMatchColorCoordDiff^2 + materialMatchMaterialCoordDiff^2;
    
    % Apply weights to the distances.  We write this in the form that is
    % more like what we do with the analytic calculation, where (w)/(w-1)
    % is applied to the first distance.
    if ((w/(1-w))^2*colorMatchDist2-materialMatchDist2 <= 0)
        response = 1;
    else
        response = 0;
    end

% Here we apply the weights to the differences in each dimension
else
    colorMatchColorCoordDiff = w*(colorMatchColorCoord-targetColorCoord); 
    materialMatchColorCoordDiff = w*(materialMatchColorCoord-targetColorCoord); 
    colorMatchMaterialCoordDiff = (1-w)*(colorMatchMaterialCoord-targetMaterialCoord);
    materialMatchMaterialCoordDiff = (1-w)*(materialMatchMaterialCoord-targetMaterialCoord);
    
    % Compute squared distance and compare
    colorMatchDist2 = colorMatchColorCoordDiff^2 + colorMatchMaterialCoordDiff^2;
    materialMatchDist2 = materialMatchColorCoordDiff^2 + materialMatchMaterialCoordDiff^2;
    if (colorMatchDist2-materialMatchDist2 <= 0)
        response = 1;
    else
        response = 0;
    end
end
