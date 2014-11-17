% cauchytest
%
% Test out that our Cauchy routines work sensibly, and try
% to understand what they do.
%
% 8/17/11  dhb, gt  Wrote this.

%% Clear
clear; close all;

%% Check on the scale factor for the one dimensional case
% x = -100:0.01:100;
% y = cauchypdf(x,0,10);
% figure; clf;
% plot(x,y);
% sum(y(:))*(x(2)-x(1))

%% Let's start with the bivariate case
axisLim = 8;
ndraws = 10000;
mu = [1 2];
var1 = 4; var2 = 1;
theCorr = 0.5;
C = [1 theCorr ; theCorr 1];
V = diag([var1 var2]);
K = sqrt(V)*C*sqrt(V');
theData1 = mvcrnd(mu,K,ndraws);
theData2 = mvcrnd(mu,K,ndraws,'mvt');
mean1 = mean(theData1,1);
mean2 = mean(theData2,1);

% Scatter plot 
figure; clf;
subplot(1,2,1); hold on
plot(theData1(:,1),theData1(:,2),'ro','MarkerSize',2,'MarkerFaceColor','r');
plot(mean1(1),mean1(2),'ko','MarkerSize',8,'MarkerFaceColor','k');
plot(mu(1),mu(2),'bo','MarkerSize',4,'MarkerFaceColor','b');
axis([-axisLim axisLim -axisLim axisLim]); axis('square');
subplot(1,2,2); hold on
plot(theData2(:,1),theData2(:,2),'go','MarkerSize',2,'MarkerFaceColor','g');
plot(mean2(1),mean2(2),'ko','MarkerSize',8,'MarkerFaceColor','k');
plot(mu(1),mu(2),'bo','MarkerSize',4,'MarkerFaceColor','b');
axis([-axisLim axisLim -axisLim axisLim]); axis('square');
drawnow;

% Histogram
nBins = 100;
edges{1} = linspace(-axisLim,axisLim,nBins);
edges{2} = linspace(-axisLim,axisLim,nBins);
figure; clf;
hist3(theData1,'Edges',edges);
xlim([-axisLim axisLim]);
ylim([-axisLim axisLim]);
xlabel('X'); ylabel('Y');

% Try to predict histogram shape with PDF
[X,Y] = meshgrid(edges{1},edges{2});
for i = 1:nBins
    for j = 1:nBins
        theMvt(i,j) = mvtpdf([X(i,j) Y(i,j)],K,1);
        thePdf(i,j) = mvcpdf([X(i,j) Y(i,j)],mu,K);
    end
end
figure; clf;
mesh(X,Y,thePdf);
xlim([-axisLim axisLim]);
ylim([-axisLim axisLim]);
xlabel('X'); ylabel('Y');
title('Population param PDF');

figure; clf;
mesh(X,Y,theMvt);
xlim([-axisLim axisLim]);
ylim([-axisLim axisLim]);
xlabel('X'); ylabel('Y');
title('Population param MVT PDF');

% Check if PDF integrates to unity
delta = X(1,2)-X(1,1);
checkValMvt = sum(theMvt(:))*delta.^2;
checkVal = sum(thePdf(:))*delta.^2;
fprintf('This number should be 1: %0.2f\n',checkVal);
fprintf('And so should this: %0.2f\n',checkValMvt);


% Now let's see how well the data are fit if instead of using
% the generated parame we instead infer the parameters from
% a set of data.  To do this, we need a set of data that
% we think behaves like our actual coeffcients are going to.
theDataToFit = theData1;
discardThresh = 3;
index = find(abs(theDataToFit(:,1)-mu(1)) < discardThresh*sqrt(var1) & abs(theDataToFit(:,2)-mu(2)) < discardThresh*sqrt(var2));
theDataToFit = theData1(index,:);
tmean = mean(theDataToFit,1);
fprintf('Population mean: %0.2f %0.2f; data mean: %0.2f %0.2f, trimmed data mean: %0.2f %0.2f\n',...
    mu(1),mu(2),mean1(1),mean1(2),tmean(1),tmean(2));
fitMu = tmean;
fitK = cov(theDataToFit);
for i = 1:nBins
    for j = 1:nBins
        theFitPdf(i,j) = mvcpdf([X(i,j) Y(i,j)],fitMu,fitK);
    end
end
figure; clf;
mesh(X,Y,theFitPdf);
xlim([-axisLim axisLim]);
ylim([-axisLim axisLim]);
xlabel('X'); ylabel('Y');
title('Fit param PDF');

