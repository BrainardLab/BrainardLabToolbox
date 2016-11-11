function response = ColorMaterialModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
% function response = ColorMaterialModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)

% Add description here. 


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
    % here we want some clarification. 
    % no weights
    cdiff1 = (cy1-targetC); 
    cdiff2 = (cy2-targetC); 
    mdiff1 = (my1-targetM);
    mdiff2 = (my2-targetM);
      
    % Compute squared length and compare
    cummulativeDiff12 = cdiff1^2 + mdiff1^2;
    cummulativeDiff22 = cdiff2^2 + mdiff2^2;
    if ((w/(1-w))^2*cummulativeDiff12-cummulativeDiff22 <= 0)
        response = 1;
    else
        response = 0;
    end
    
else
    cdiff1 = w*(cy1-targetC); 
    cdiff2 = w*(cy2-targetC); 
    mdiff1 = (1-w)*(my1-targetM);
    mdiff2 = (1-w)*(my2-targetM);
    
    % Compute squared length and compare
    cummulativeDiff12 = cdiff1^2 + mdiff1^2;
    cummulativeDiff22 = cdiff2^2 + mdiff2^2;
    if (cummulativeDiff12-cummulativeDiff22 <= 0)
        response = 1;
    else
        response = 0;
    end
end


