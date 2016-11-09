function response = CMModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
% function response = CMModelSimulateResponse(targetC,targetM, cy1,cy2,my1, my2, sigma, w)

% Simulate a trial given target and a competitor pair.

% 
targetC = targetC + normrnd(0,sigma); 
targetM = targetM + normrnd(0,sigma); 
cy1 = cy1 + normrnd(0,sigma); 
cy2 = cy2 + normrnd(0,sigma); 
my1 = my1 + normrnd(0,sigma); 
my2 = my2 + normrnd(0,sigma); 

cdiff1 = w*(cy1-targetC); % weighted difference on color dimension
cdiff2 = w*(cy2-targetC); % weighted difference on material dimension
mdiff1 = (1-w)*(my1-targetM); 
mdiff2 = (1-w)*(my2-targetM); 

%disp([cdiff1, cdiff2, mdiff1, mdiff2])
cummulativeDiff1 = sqrt(cdiff1^2 + mdiff1^2); 
cummulativeDiff2 = sqrt(cdiff2^2 + mdiff2^2); 


if (abs(cummulativeDiff1)-abs(cummulativeDiff2) <= 0)
    response = 1;
else
    response = 0;
end

