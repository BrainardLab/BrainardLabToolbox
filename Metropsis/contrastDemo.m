function contrastDemo
% Display positive and negative contrast values for each cone
%
% Syntax:
%  	 contrastDemo
%
% Description:
%    This tutorial illustrates the effects of increasing and decreasing
%    contrast values for each cone. Using GLWindow, it creates a 6x6 grid
%    where each row represents a range of either positive or negative 
%    contrast values for a particular cone. Maximum and minimum contrast 
%    values were calculated from the calibration file of the Metropsis 
%    Display++ monitor, but the program can be applied to other monitors 
%    with some tweaking. The program assumes a gray background with rgb  
%    values [0.5 0.5 0.5]. It runs automatically and terminates when the 
%    user presses any key.

% Inputs:
%    none
%
% Outputs:
%    none
%
% Optional key/value pairs:
%    none

% History:
%    07/10/19  dce       Wrote routine

%load calibration information for the Display++ monitor
[cal,cals] = LoadCalFile('MetropsisCalibration', [], getpref('BrainardLabToolbox','CalDataFolder'));
load T_cones_ss2 %cone fundamentals
cal = SetSensorColorSpace(cal, T_cones_ss2, S_cones_ss2);
cal = SetGammaMethod(cal, 0);

%get information on the display
disp = mglDescribeDisplays;
last = disp(end); %we will be using the last display
size = last.screenSizePixel;

%Create matrix and fill with contrast values for each cone. Maximum and
%minimum values were calculated to six decimal places through trial and 
%error 
contrastValues = zeros(6,6);
contrastValues(1,:) = 0:0.0294888:0.147444; %l contrast up (max 14.74%)
contrastValues(2,:) = 0:-0.0294888:-0.147444; %l contrast down (min -14.74%)
contrastValues(3,:) = 0:0.033078:0.165390; %m contrast up (max 16.54%)
contrastValues(4,:) = 0:-0.033078:-0.165390; %m contrast down (min -16.54%)
contrastValues(5,:) = 0:0.179616:0.898080; %s contrast up (max 89.81%)
contrastValues(6,:) = 0:-0.179616:-0.898080; %s contrast down (min -89.81%)

%convert contrast values to RGB values and store in 3D matrix
mondrianColors = zeros(6,6,3);
mondrianColors(:,:,1) = contrastValues;
for i = 1:6
    for j = 1:6
        %convert each contrast value to an rgb triplet 
        switch i
            case {1,2} %l cone
                mondrianColors(i,j,:) = contrastTorgb(cal, [mondrianColors(i,j,1) 0 0]);
            case {3,4} %m cone
                mondrianColors(i,j,:) = contrastTorgb(cal, [0 mondrianColors(i,j,1) 0]);
            case {5,6} %s cone
                mondrianColors(i,j,:) = contrastTorgb(cal, [0 0 mondrianColors(i,j,1)]);
        end
        %gamma correction using automatic routine
        mondrianColors(i,j,:) = PrimaryToSettings(cal,mondrianColors(i,j,:));
    end
end

%create window and add grid
win = GLWindow('BackgroundColor', PrimaryToSettings(cal, [0.5 0.5 0.5]),'SceneDimensions', size);
win.addMondrian(6, 6, size, mondrianColors, 'Border', 7);

%add labels for rows
xPos = size(1) * (-5/12);
yPos = size(2);
win.addText('L contrast up', 'Center', [xPos (yPos*5/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r1');
win.addText('L contrast down', 'Center', [xPos (yPos*3/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r2');
win.addText('M contrast up', 'Center', [xPos (yPos*1/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r3');
win.addText('M contrast down', 'Center', [xPos (yPos*-1/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r4');
win.addText('S contrast up', 'Center', [xPos (yPos*-3/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r5');
win.addText('S contrast down', 'Center', [xPos (yPos*-5/12)], 'FontSize',...
    50, 'Color', [0 0 0], 'Name', 'r6');

%open window and start character listening
win.open;
ListenChar(2);
FlushEvents;

%continue drawing until the user presses a key. Then clean up
while ~CharAvail
    win.draw;
end
ListenChar(0);
win.close;

end