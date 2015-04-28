function response = ThurstonianScalingSimulateResponse(y1,y2,sigma)
% response = ThurstonianScalingSimulateResponse(y1,y2,sigma)
%
% Simulate a trial given a stimulus pair.  Response is 1 (y1 is "more X")
% if the noisy difference is positive.
%
% We take noise as sqrt(2)*sigma because sigma represents the noise of each
% stimulus.
%
% 4/27/15  dhb  Wrote from MLDS version.

diff = y1-y2;
if (diff + normrnd(0,sqrt(2)*sigma) >= 0)
    response = 1;
else
    response = 0;
end

end





