% EllipseTest
%
% Put an ellipse through a set of sample points.
%
% This illustrates use of FitEllipseQ, EllipsoidMatricesGenerate, and
% PointsOnEllipseQ.

%% Clear
clear; close all;

%% Generate some elliptical data
%
% Parameter format is reciprocol major axis length, reciprocol minor axis
% length, major axis angle (clockwise from x axis in degrees, in range -90
% to 90);
ellParamsTrue = [0.5 2 45];
nDataPoints = 10;
noiseSd = 0.1;
theDirsFit = UnitCircleGenerate(nDataPoints);
[~,~,QTrue] = EllipsoidMatricesGenerate(ellParamsTrue,'dimension',2);
theDataToFit = PointsOnEllipseQ(QTrue,theDirsFit);
theDataToFit = theDataToFit + normrnd(0,noiseSd,2,nDataPoints);

%% Fit using general routine
[ellParamsFit,fitA,fitAinv,fitQ,fitErr] = FitEllipseQ(theDataToFit);
[~,~,QFit] = EllipsoidMatricesGenerate(ellParamsFit,'dimension',2);
nPlotPoints = 200;
theDirsPlot = UnitCircleGenerate(nPlotPoints);
theEllTrue = PointsOnEllipseQ(QTrue,theDirsPlot);
theEllFit = PointsOnEllipseQ(QFit,theDirsPlot);

%% Plot
theColors = ['r' 'k' 'b' 'b' 'y' 'c'];
figure; clf; hold on;
plot(theDataToFit(1,:),theDataToFit(2,:),[theColors(1) 'o'],'MarkerFaceColor',theColors(1),'MarkerSize',12);
theLim = 2;
xlim([-theLim theLim]);
ylim([-theLim theLim]);
axis('square');
plot(theEllTrue(1,:),theEllTrue(2,:),'k.','MarkerSize',4,'MarkerFaceColor','k');
plot(theEllFit(1,:),theEllFit(2,:),'r.','MarkerSize',8,'MarkerFaceColor','r');
