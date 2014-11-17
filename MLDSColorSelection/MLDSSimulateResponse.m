%% response1 = SimulateResponse1(x,y1,y2,sigma,mapFunction)
%
% Simulate a trial given target and pair.
% The passed mapFunction simulates the effect of context change
% between x domain and y domain
function response = MLDSSimulateResponse1(x,y1,y2,sigma,mapFunction)

yOfX = mapFunction(x);
diff1 = y1-yOfX;
diff2 = y2-yOfX;
if (abs(diff1)-abs(diff2) + normrnd(0,sigma) <= 0)
    response = 1;
else
    response = 0;
end

end





