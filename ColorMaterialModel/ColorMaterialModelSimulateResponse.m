function response = ColorMaterialModelSimulateResponse(targetC, targetM, cy1, cy2,my1, my2, w, sigma)
% function response = ColorMaterialModelSimulateResponse(targetC, targetM, cy1, cy2,my1, my2, w, sigma)
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
%       targetC  - target position on color dimension (should be fixed to 0).
%       targetM  - target position on material dimension (should be fixed to 0).
%
%       cy1 - inferred position on the color dimension for the first competitor in the pair
%       my1 - inferred position on the material dimension for the first competitor in the pair
%       cy2 - inferred position on the color dimension for the second competitor in the pair
%       my2 - inferred position on the material dimension for the second competitor in the pair
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
targetC = targetC; 
targetM = targetM; 
cy1 = cy1 + normrnd(0,sigma); 
cy2 = cy2 + normrnd(0,sigma); 
my1 = my1 + normrnd(0,sigma); 
my2 = my2 + normrnd(0,sigma); 

if (DO_APPROX) 
    % CLARIFICATION
    % no weights
    cdiff1 = (cy1-targetC); 
    cdiff2 = (cy2-targetC); 
    mdiff1 = (my1-targetM);
    mdiff2 = (my2-targetM);
      
    % Compute squared distance and compare
    cummulativeDiff1= cdiff1^2 + mdiff1^2;
    cummulativeDiff2 = cdiff2^2 + mdiff2^2;
    
    % CLARIFICATION
    if ((w/(1-w))^2*cummulativeDiff1-cummulativeDiff2 <= 0)
        response = 1;
    else
        response = 0;
    end
    
else
    cdiff1 = w*(cy1-targetC); 
    cdiff2 = w*(cy2-targetC); 
    mdiff1 = (1-w)*(my1-targetM);
    mdiff2 = (1-w)*(my2-targetM);
    
    % Compute squared distance and compare
    cummulativeDiff1 = cdiff1^2 + mdiff1^2;
    cummulativeDiff2 = cdiff2^2 + mdiff2^2;
    if (cummulativeDiff1-cummulativeDiff2 > 0)
        response = 1;
    else
        response = 0;
    end
end
