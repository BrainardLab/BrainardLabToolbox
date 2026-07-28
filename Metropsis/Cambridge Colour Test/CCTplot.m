function [theFig,u_prime,v_prime,fitArea,fitMajorAxisLength,fitMajorAxisAngleDegs,fitMajorMinorAxisRatio] = CCTplot(fName,varargin)
% Plots discrimination points using data from Cambridge Colour Test text files
%
% Syntax:
%    theFig = CCTplot(fName)
%
%
% Description:
%    The Metropsis system implements the Cambridge Colour Test and outputs
%    data in an idiosyncratic file format.  This routine parses that file
%    to obtain the threshold contour in the u',v' chromaticity plane and
%    makes a plot.
%
% Inputs
%     fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.
%
% Outputs:
%     theFig         - Handle to the plot
%     u_prime        - u_prime coordinates at threshold
%     v_prime        - v_prime coordinates at threshold
%     fitArea        - area of fit ellipse
%     fitMajorAxisLength - as its name suggests
%     fitMajorAxisAngleDegs - as its name suggests. See EllipseAreaOrientation for angle convention
%     fitMajorMinorAxisRation - ratio of lengths of major to minor axis
%
% Optional key/value pairs
%     'figHandle'    - Figure handle to plot in.  Creates new figure if empty
%                      (default empty).
%     'plotColor'    - Color arg accepted by plot (default black).
%
% See also:
%

% History:
%    04/11/19  dce       Wrote it.  File parsing code provided by ncp.
%    04/12/19  dce, dhb  Comments and tweaking, added ellipse fitting code
%    05/30/19  dce       Minor edits, moved file parsing code to a separate routine  

% Examples:
%{
    % Need to point to a data file available on the machine this is being
    % run on.
    CCTplot('/Users/geoffreyaguirre/Documents/Deena CCT spreadsheets/TOME_DEENA_2.txt')
    CCTplot('/Volumes/Users1/Dropbox (Aguirre-Brainard Lab)/MTRP_data/Exp_CCTE/Subject_TOME_BURGE/TOME_BURGE_1.txt')
    CCTplot('/Volumes/Users1/Dropbox (Aguirre-Brainard Lab)/MTRP_data/Exp_CCTE/Subject_DEENA ELUL/DEENA ELUL_2 copy.txt')
%}

% CCT-E interpretation info
%
% Normal: small ellipse with axis ratio less than 2 
% Abnormal: elongated on one axis 
% Protanope: point towards u'=0.678, v'=0.501
% Deuteranope: point towards u'=-1.217, v'=0.782
% Tritanope: point towards u'=0.257, v' =0.0 (vertical)
% For some dichromats, will approximate 2 parallel lines 


% Parse key/value pairs
p = inputParser;
p.addParameter('figHandle',[],@(x) (isempty(x) | ishandle(x)));
p.addParameter('plotColor','k',@(x) (ischar(x) | isvector(x)));
p.parse(varargin{:});

% Read the file
[center_v_prime_w, center_u_prime_w, azimuthsTable] = ParseCCTTextfile(fName);

% Get table length
highestIndex = size(azimuthsTable, 1);

% Calculate and store u_prime coordinates
u_prime = zeros(highestIndex,1);
for i = 1:highestIndex
    u_prime(i) = cos(azimuthsTable(i,3)) * azimuthsTable(i,1) + center_u_prime_w;
end

% Calculate and store v_prime coordinates
v_prime = zeros(highestIndex,1);
for i = 1:highestIndex
    v_prime(i) = sin(azimuthsTable(i,3)) * azimuthsTable(i,1) + center_v_prime_w;
end

% Try to fit an ellipse to the data

% We have several ellipse fitting routines.
theData = [u_prime-center_u_prime_w v_prime-center_v_prime_w zeros(size(u_prime))]';
initialFactor = 10;   % Was 15, but some fits didn't converge well
ellRanges = max(theData,[],2)-min(theData,[],2);
ellParams0 = [1./ellRanges'.^0.5 0 0 0]';
ellParams0(1:3) = ellParams0(1:3)*initialFactor;
ellParams0(isinf(ellParams0)) = 1;
[fitA,fitAinv,fitQ,fitEllParams] = EllipsoidFit(theData,ellParams0,false,true);
fitCenter = [center_u_prime_w center_v_prime_w 0]';

% Get fit ellipse area and major axis orientation/length
[fitArea, fitMajorAxisLength, fitMajorAxisAngleDegs, fitMinorAxisLength] = EllipseAreaOrientation(fitQ);
fitMajorAxisVector = fitMajorAxisLength*[cosd(fitMajorAxisAngleDegs) sind(fitMajorAxisAngleDegs)]'/2;
fitMajorMinorAxisRatio = fitMajorAxisLength/fitMinorAxisLength;
% The commented out quantity should always be 1.
% fitMajorAxisVector'*fitQ(1:2,1:2)*fitMajorAxisVector

% Get ellipse from fit
nThetaEllipse = 200;
circleIn2D = UnitCircleGenerate(nThetaEllipse);
circleIn3DPlane = [circleIn2D(1,:) ; circleIn2D(2,:) ; zeros(size(circleIn2D(1,:)))];
fitEllipseIn3DPlane = PointsOnEllipsoidFind(fitQ,circleIn3DPlane,fitCenter);
fitEllipseIn2D = fitEllipseIn3DPlane(1:3,:);

% Plot u_prime and v_prime
if (isempty(p.Results.figHandle))
    theFig = figure; clf; hold on
    set(theFig,'Position',[15   630   900   700]);
end
set(gca,'FontName','Helvetica','FontSize',16);
plot(u_prime,v_prime,'ko','MarkerEdgeColor',p.Results.plotColor,'MarkerFaceColor',p.Results.plotColor','MarkerSize',6);
plot(fitEllipseIn2D(1,:),fitEllipseIn2D(2,:),p.Results.plotColor,'LineWidth',2);
plot([fitCenter(1)-fitMajorAxisVector(1) fitCenter(1)+fitMajorAxisVector(1)],[fitCenter(2)-fitMajorAxisVector(2) fitCenter(2)+fitMajorAxisVector(2)],p.Results.plotColor,'LineWidth',2);
plot([fitCenter(1) fitCenter(1)+ 0.678],[fitCenter(2) fitCenter(2)+ 0.501],'r:','LineWidth',1);
plot([fitCenter(1) fitCenter(1)+ -1.217],[fitCenter(2) fitCenter(2)+ 0.782],'g:','LineWidth',1);
plot([fitCenter(1) fitCenter(1)+ 0.257],[fitCenter(2) fitCenter(2)+ 0.0],'b:','LineWidth',1);

xlim([0.1 0.3]);
ylim([0.35 0.55]);
axis('square');
title([fName(1:end-4) ' CCTE Results'], 'Interpreter','none');
xlabel('u\_prime','FontSize',18);
ylabel('v\_prime','FontSize',18);
end






