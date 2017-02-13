% 1-.m
clear; close all; 
x = 0:10;  
y = 10*x; 
overRange = linspace(0,10,100); 

funInterp = interp1(x,y, overRange); 
funGridded = griddedInterpolant(x,y); 

figure; clf; hold on; 
plot(x,y, 'ko')
plot(overRange, funInterp,'k-'); 

nDimensions = 1; 
for d = 1:nDimensions
    plot(funGridded.GridVectors{d},funGridded.Values, 'g--');
end

%ndgrid