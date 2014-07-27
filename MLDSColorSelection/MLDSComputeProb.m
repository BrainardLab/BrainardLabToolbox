function p = MLDSComputeProb(x,y1,y2,sigma,mapFunction)
% function p = MLDSComputeProb(x,y1,y2,sigma,mapFunction)
%
% Computes the probability of the first competitor being chosen given the  
% inferred position of the target and the two competitors in the pair. 
%
%   Inputs: 
%       x  - inferred target position . 
%       y1 - inferred position of the first element in the pair
%       y2 - inferred position of the second element in the pair
%       sigma - fixed standard deviation of a cummulative normal distribution
%       mapFunction - function that determins the mapping from x to y domain. 
%                     it can be used to model the effect of context. 
%                     we typically use the identity function. 
%   Output: 
%       p - probability of first competitor in the pair being chosen given the
%           inferred target position. 
% 
% 05/03/12 dhb   Wrote it. 
% 06/13/13 ar    Added many comments. 

% Apply the context mapping function to the target. 
% Then compute the distance between the target and each of the competitor
% pairs. Find the probability that the first competitors is closer to the
% target than the second. Assume normal distribution of "distances" 
% with mean at 0 and standard deviation equal to sigma. 
% Ensure the returned probability is not 0 or 1. 

yOfX = mapFunction(x);
diff1 = y1-yOfX; % distance between the target and the first element of the pair
diff2 = y2-yOfX; % distance between the target and the second element of the pair. 
diffDiff = abs(diff1)-abs(diff2); 
p = normcdf(-diffDiff,0,sigma);
if (p == 0)
    p = 0.0001;
elseif (p == 1)
    p = 0.9999;
end
end
