% GetM_RGBToXYZ
% 
% Compute the matrix that takes us between standardized camera
% RGB values and XYZ in cd/m2.
%
% 8/14/11  dhb  Wrote it.

% Clear and close
clear; close all;

% Load camera calibration information
CamCal = LoadCamCal('standard');

% Load XYZ and get matrix from standardized RGB to XYZ
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,CamCal.S_camera);
M_RGBToXYZ = ((CamCal.T_camera')\(T_xyz'))';

% Get matrix that undoes conversion from LMS to isomerizations
M_undoisom = diag(1./CamCal.LMSToIsomerizations);

% Get matrix that undoes standardized RGB to nominal LMS
M_RGBToLMS = CamCal.M_RGBToLMS;
M_LMSToRGB = inv(M_RGBToLMS);

% Put it together
M_LMSIsomToXYZ = M_RGBToXYZ*M_LMSToRGB*M_undoisom;

% We could check if this more or less works by comparing Y values
% to the LUM matrix we provide.
load('/Volumes/ImageDatabase/NaturalImageProject/Images/out/cd29A/DSC_0001_LMS.mat')
[LMS_calFormat,nX,nY] = ImageToCalFormat(LMS_Image);
XYZ_calFormat = M_LMSIsomToXYZ*LMS_calFormat;
XYZ_Image = CalFormatToImage(XYZ_calFormat,nX,nY);
Y_calFormat = XYZ_calFormat(2,:);

load('/Volumes/ImageDatabase/NaturalImageProject/Images/out/cd29A/DSC_0001_LUM.mat')
LUM_calFormat = ImageToCalFormat(LUM_Image);

% Plot
figure; clf; hold on
plot(LUM_calFormat,Y_calFormat,'ro','MarkerSize',2,'MarkerFaceColor','r');
axis('square');
axis([0 2.5e4 0 2.5e4]);
