% BayesMvnNormalTest
%
% Test program for MvnNormal model.
%
% 10/23/06  dhb  Wrote it.

% Clear
clear; close all;

% Define parameters

T1 = [1 1 0 ; 0 1 0; 0.5 -0.5 1];
T2 = [1 1 0 ; 0 1 -1];
T = T2;
dataDim = size(T,1);

ux = [1 5 3]';
Kx1 = [1 0.5 0.3; 0.5 2 0.4 ; 0.3 0.4 0.6];
Kx2 = [1 0 0 ; 0 2 0 ; 0 0 0.6];
Kx = Kx1;

noiseVar = 0.01;
un = ones(dataDim,1);
Kn = noiseVar*eye(dataDim);
nSimulate = 1000;

% Draw a bunch of samples from the prior
theXs = BayesMvnNormalPriorDraw(nSimulate,ux,Kx);
theNs = BayesMvnNormalNoiseDraw(nSimulate,un,Kn);
theYs = T*theXs+theNs;

% Now recover xHat for each x
theXHats = BayesMvnNormalPosteriorMean(theYs,T,ux,Kx,un,Kn);    
figure(1); clf; 
subplot(1,3,1); hold on
plot(theXs(1,:),theXHats(1,:),'ro','MarkerFaceColor','r','MarkerSize',2);
plot([-3 5],[-3 5],'k');
axis([-3 5 -3 5]); axis('square');
title('Coordinate 1'); xlabel('Simulated x'); ylabel('Estimated x');
subplot(1,3,2); hold on
plot(theXs(2,:),theXHats(2,:),'ro','MarkerFaceColor','r','MarkerSize',2);
plot([0 10],[0 10],'k');
axis([0 10 0 10]); axis('square');
title('Coordinate 2'); xlabel('Simulated x'); ylabel('Estimated x');
subplot(1,3,3); hold on
plot(theXs(3,:),theXHats(3,:),'ro','MarkerFaceColor','r','MarkerSize',2);
plot([0 6],[0 6],'k');
axis([0 6 0 6]); axis('square');
title('Coordinate 3'); xlabel('Simulated x'); ylabel('Estimated x');

% Compute simulated and analytic SSE
theEstimationErrors = theXs-theXHats;
simulatedSSE = mean(diag(theEstimationErrors'*theEstimationErrors));
simulatedSSESEM = std(diag(theEstimationErrors'*theEstimationErrors))/sqrt(nSimulate);
analyticSSE = BayesMvnNormalExpectedSSE(T,ux,Kx,un,Kn);
fprintf('Analytic SSE = %g, Simulated SSE = %g +/- %g, z-score = %g\n',analyticSSE, ...
    simulatedSSE,simulatedSSESEM,(analyticSSE-simulatedSSE)/simulatedSSESEM);

% Verify that analytic and explicit (likelihood*prior) computations of posterior agree up to scale factor
% for one y and some set of x.
y = T*ux; 

posteriorProbsAnalytic = BayesMvnNormalPosteriorProb(theXs,y,T,ux,Kx,un,Kn);
posteriorProbsExplicit = BayesMvnNormalPriorProb(theXs,ux,Kx) .* ...
    BayesMvnNormalLikelihood(y,theXs,T,un,Kn);

figure(2); clf;
plot(posteriorProbsAnalytic,posteriorProbsExplicit,'ro');
title('Should be a line');
xlabel('Analytic'); ylabel('Explicit');
