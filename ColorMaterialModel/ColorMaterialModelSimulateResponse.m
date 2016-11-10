function response = CMModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
% function response = CMModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)

% Simulate a trial given target and a competitor pair.

%% Prevent pathological values of w
if (w == 0)
    w = 0.0001;
elseif (w == 1)
    w = 0.9999;
end

% Parameters
DO_APPROX = false;

% 
targetC = targetC; 
targetM = targetM; 
cy1 = cy1 + normrnd(0,sigma); 
cy2 = cy2 + normrnd(0,sigma); 
my1 = my1 + normrnd(0,sigma); 
my2 = my2 + normrnd(0,sigma); 

if (DO_APPROX)
    cdiff1 = (cy1-targetC); % weighted difference on color dimension
    cdiff2 = (cy2-targetC); % weighted difference on material dimension
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
    cdiff1 = w*(cy1-targetC); % weighted difference on color dimension
    cdiff2 = w*(cy2-targetC); % weighted difference on material dimension
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


