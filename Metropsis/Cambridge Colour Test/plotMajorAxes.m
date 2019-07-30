function plotMajorAxes(varargin)
%% Parse input
p = inputParser;
p.addParameter('groupSubjects', false, @(x) (islogical(x)));
p.parse(varargin{:});

%% Initial parameters
% Subject IDs 
subjects = [3003 3004 3006 3007 3009 3011 3012 3016 3019]; 

% Plot colors 
if p.Results.groupSubjects
    colors = [1 1 0; 0 0 1; 0 1 1; 0 1 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1]; 
else
    colors = [1 1 0; 1 0 1; 0 1 1; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330];
end

% Templates for directory name and file name
directoryTemplate = '/Users/deena/Dropbox (Aguirre-Brainard Lab)/MTRP_data/Exp_CCTE/Subject_MELA_';
fileTemplate = 'MELA_';

% Initialize figure
close all; 
figure(1)
hold on;

%% Loop through subjects and add their fit lines to plot
for ii = 1:length(subjects)
    % Build directory name and filename
    subjectID = subjects(ii);
    directory = [directoryTemplate num2str(subjectID)];
    fileName = [fileTemplate num2str(subjectID) '_1.txt'];
    
    % Parse the CCTE file to get subject data
    [center_v_prime_w, center_u_prime_w, azimuthsTable] = ParseCCTTextfile(fullfile(directory, fileName));
    
    % Calculate u_prime and v_prime coordinates
    highestIndex = size(azimuthsTable, 1);
    u_prime = zeros(highestIndex,1);
    v_prime = zeros(highestIndex,1);
    for i = 1:highestIndex
        u_prime(i) = cos(azimuthsTable(i,3)) * azimuthsTable(i,1) + center_u_prime_w;
        v_prime(i) = sin(azimuthsTable(i,3)) * azimuthsTable(i,1) + center_v_prime_w;
    end
    
    % Fit ellipse to subject data
    ellipseFit = fitEllipse(u_prime, v_prime, center_u_prime_w, center_v_prime_w);
    
    % Find major axis line by calculating best fit line for ellipse 
    % coordinates. Add this line to the plot 
    fit = polyfit(ellipseFit(1,:),ellipseFit(2,:),1);
    plot(ellipseFit(1,:), polyval(fit,ellipseFit(1,:)), 'Color',...
        colors(ii,:), 'LineWidth', 1.5); 
end 

%% Clean up plot
f=get(gca,'Children');

% Legend 
if p.Results.groupSubjects
    legend(f(9:7), 'Deuteranopes Long', 'Deuteranopes Short', 'Protanopes', 'AutoUpdate','off');
else 
    legend(['MELA\_3003'; 'MELA\_3004'; 'MELA\_3006';'MELA\_3007';...
        'MELA\_3009'; 'MELA\_3011'; 'MELA\_3012'; 'MELA\_3016'; 'MELA\_3019'], 'AutoUpdate','off'); 
end
uistack(f(9),'top'); %  Move MELA_3003 line to top 
plot(center_u_prime_w, center_v_prime_w, 'r*', 'HandleVisibility','off')
axis([0.12 0.28 0.45 0.5]);
title('CCT Major Axes', 'FontSize', 16);
xlabel('u\_prime', 'FontSize', 14);
ylabel('v\_prime', 'FontSize', 14);

%% Save results 
dir = '/Users/deena/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/projectDichromat/CCTE major axis plots'; 
if p.Results.groupSubjects
    fName = 'groupPlot';
else 
    fName = 'subjectPlot';
end 
print('-bestfit', fullfile(dir, fName), '-dpdf');
end

% Ellipse-fitting routine from dhb
function fitEllipseIn2D = fitEllipse(u_prime, v_prime, center_u_prime_w, center_v_prime_w)
theData = [u_prime-center_u_prime_w v_prime-center_v_prime_w zeros(size(u_prime))]';
initialFactor = 15;
ellRanges = max(theData,[],2)-min(theData,[],2);
ellParams0 = [1./ellRanges'.^0.5 0 0 0]';
ellParams0(1:3) = ellParams0(1:3)*initialFactor;
ellParams0(isinf(ellParams0)) = 1;
[fitA,fitAinv,fitQ,fitEllParams] = EllipsoidFit(theData,ellParams0,false,true);
fitCenter = [center_u_prime_w center_v_prime_w 0]';

% Get ellipse from fit
nThetaEllipse = 200;
circleIn2D = UnitCircleGenerate(nThetaEllipse);
circleIn3DPlane = [circleIn2D(1,:) ; circleIn2D(2,:) ; zeros(size(circleIn2D(1,:)))];
fitEllipseIn3DPlane = PointsOnEllipsoidFind(fitQ,circleIn3DPlane,fitCenter);
fitEllipseIn2D = fitEllipseIn3DPlane(1:3,:);
end