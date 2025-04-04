function CCTHandbookPlots(fName)
% Plots CCT subject data against various datasets from the CCT handbook
%
% Syntax:
%    CCTHandbookPlots(fName)
%
% Description:
%    This routine plots example CCT results from the Cambridge Colour Test
%    handbook (protanopic, deuteranopic, anomalous trichromatic, and normal)
%    against data obtained from subjects in the Metropsis implementation of
%    the CCT. It uses the CCTplot routine to parse subjects' results files
%    and saves results as PDF files in an experimental directory.(Data 
%    points were obtained from the CCT handbook using WebPlotDigitizer, a
%    free online program). 
%
% Inputs
%    fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.
%
% Outputs
%    none
%
% Optional key-value pairs
%    none

% History:
%    05/31/19  dce       Wrote routine
%    06/06/19  dce       Added ellipse-fitting code from dhb
%    06/26/19  dce       Added code to create folder and save as PDF

% Examples:
%{
    CCTHandbookPlots('/Users/geoffreyaguirre/Documents/Deena CCT spreadsheets/TOME_BURGE_1 copy.txt')
%}

%parse subject ID from filename and create folder to store plots
subjectID = fName(end-14:end-6); %changed for new file naming system 
[~, userID] = system('whoami');
userID = strtrim(userID);
directory = fullfile('Users',userID,'Dropbox (Aguirre-Brainard Lab)/MELA_analysis/projectDichromat/CCTE plots');
mkdir(directory, subjectID);

%normal observer
xn = [0.19402985074626866, 0.1962686567164179, 0.19402985074626866,...
    0.20373134328358208, 0.20074626865671644, 0.19925373134328359,...
    0.20149253731343283, 0.19328358208955226, 0.1947761194029851,...
    0.20298507462686569, 0.20298507462686569, 0.19701492537313434,...
    0.19925373134328359, 0.1962686567164179, 0.20298507462686569,...
    0.20074626865671644, 0.1955223880597015, 0.1955223880597015,...
    0.20298507462686569, 0.19402985074626866];
yn = [0.47204724409448684, 0.46102362204724284, 0.4633858267716523,...
    0.4641732283464554, 0.46417322834645536, 0.46338582677165224,...
    0.46889763779527427, 0.46889763779527427, 0.47677165354330564,...
    0.47677165354330564, 0.47362204724409307, 0.4759842519685025,...
    0.4751968503936994, 0.47047244094488055, 0.46968503937007744,...
    0.47677165354330564, 0.47362204724409307, 0.4657480314960617,...
    0.47204724409448684, 0.46653543307086487];
fit = fitEllipse(xn', yn');

figure(1) = CCTplot(fName);
hold on;
plot(xn, yn, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(fit(1,:), fit(2,:), 'b', 'LineWidth', 2);
title('Comparison of Subject Results to Normal Observer Results',...
    'FontSize', 18);
legend('Subject', 'Subject Fit', 'Normal Observer', 'Normal Fit');

normalName = [directory, '/', subjectID, '/', subjectID,'_normal'];
print('-bestfit', normalName, '-dpdf');

%protanope
xp = [0.18775510204081636, 0.13673469387755105, 0.1693877551020408,...
    0.1877551020408163, 0.25918367346938775, 0.2204081632653061,...
    0.2142857142857143, 0.1938775510204081, 0.2061224489795918,...
    0.20816326530612245, 0.2020408163265306, 0.19795918367346937, 0.2,...
    0.2081632653061225, 0.19591836734693874, 0.20408163265306123, 0.2];
yp = [0.4771456527816606, 0.47233715403969806, 0.462510483645513,...
    0.464816885658373, 0.474014537321778, 0.4796477495107633,...
    0.46928990774391943, 0.4792843164663125, 0.4794520547945205,...
    0.46509644953871965, 0.4670673748951636, 0.46906625663964213,...
    0.48142298015096446, 0.4774252166620073, 0.4772574783337992,...
    0.47120492032429406, 0.4773133911098686];
fit = fitEllipse(xp', yp');

figure(2) = CCTplot(fName);
hold on;
plot(xp, yp, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(fit(1,:), fit(2,:), 'b', 'LineWidth', 2);
title('Comparison of Subject Results to Protanope Results', 'FontSize', 18);
legend('Subject', 'Subject Fit', 'Protanope', 'Protanope Fit');

protanopeName = [directory, '/', subjectID, '/', subjectID,'_protanope'];
print('-bestfit', protanopeName, '-dpdf');

%deuteranope
xd = [0.26640832851359164, 0.22490952656366187, 0.24329422457242006,...
    0.2140080971659919, 0.21036437246963563, 0.1407964967363463,...
    0.1468247541931752, 0.1803718086424853, 0.2102751383954391,...
    0.19074774849210938, 0.18717342807568368, 0.18836817318020324,...
    0.20302734859125834, 0.19327604726100964, 0.1973552342394447,...
    0.19559910765925798, 0.20437974056019162, 0.20085677931091456,...
    0.20002511773940332, 0.20263789143187633];
yd = [0.46844418739155574, 0.4771494670742791, 0.4545137569197719,...
    0.45890109890109887, 0.45525737420474255, 0.46895480459390226,...
    0.4860034702139965, 0.4834280756837147, 0.4772089564570767,...
    0.48094687267619596, 0.4602296951169131, 0.4663223994051061,...
    0.46016524828554894, 0.45898537552672886, 0.4755053788316945,...
    0.47551251755763024, 0.47547682392795165, 0.4781252912501032,...
    0.46671403784185733, 0.47197170949351397];
fit = fitEllipse(xd', yd');

figure(3) = CCTplot(fName);
hold on;
plot(xd, yd, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(fit(1,:), fit(2,:), 'b', 'LineWidth', 2);
title('Comparison of Subject Results to Deuteranope Results',...
    'FontSize', 18);
legend('Subject', 'Subject Fit', 'Deuteranope', 'Deuteranope Fit');

deuteranopeName = [directory, '/', subjectID, '/', subjectID,...
    '_deuteranope'];
print('-bestfit', deuteranopeName, '-dpdf');

%anomalous trichromat
xa = [0.17755102040816323, 0.17959183673469387, 0.19183673469387752,...
    0.22653061224489796, 0.20612244897959187, 0.2020408163265306,...
    0.20816326530612245, 0.21224489795918366, 0.2204081632653061,...
    0.21020408163265303, 0.2142857142857143, 0.19183673469387752,...
    0.19387755102040816, 0.19795918367346943, 0.2061224489795918,...
    0.2020408163265306, 0.20204081632653065, 0.2];
ya = [0.4755381604696673, 0.4693597987140062, 0.47544031311154594,...
    0.45876432764886776, 0.4527397260273973, 0.4568772714565278,...
    0.46094492591557173, 0.4588621750069891, 0.4690802348336595,...
    0.47531450936539005, 0.47117696393625946, 0.46516634050880623,...
    0.46309756779424105, 0.46101481688565843, 0.4753424657534246,...
    0.4774252166620073, 0.4733156276209114, 0.4651104277327369];
fit = fitEllipse(xa', ya');

figure(4) = CCTplot(fName);
hold on;
plot(xa, ya, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(fit(1,:), fit(2,:), 'b', 'LineWidth', 2);
title('Comparison of Subject Results to Anomalous Trichromat Results',...
    'FontSize', 18);
legend('Subject', 'Subject Fit', 'Anomalous Trichromat',...
    'Anomalous Trichromat Fit');

trichromatName = [directory, '/', subjectID, '/', subjectID,...
    '_anomalousTrichromat'];
print('-bestfit', trichromatName, '-dpdf');
end

%ellipse-fitting routine from dhb
function fitEllipseIn2D = fitEllipse(u_prime, v_prime)
center_u_prime_w = 0.1977;
center_v_prime_w = 0.4689;
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