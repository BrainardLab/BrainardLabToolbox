function contrastDemo

%load calibration information for the monitor 
[cal,cals] = LoadCalFile('MetropsisCalibration',[],getpref('BrainardLabToolbox','CalDataFolder'));
load T_cones_ss2 %cone fundamentals
cal = SetSensorColorSpace(cal,T_cones_ss2, S_cones_ss2);
cal = SetGammaMethod(cal,0);

%get information on the display
disp = mglDescribeDisplays;
last = disp(end); %we will be using the last display
size = last.screenSizePixel;

%create matrix and fill with contrast values for each cone 
contrastValues = zeros(6, 6); 
contrastValues(1,:) = 0:0.0294888:0.147444; %l contrast up 
contrastValues(2,:) = 0.147444:-0.0294888:0; %l contrast down
contrastValues(3,:) = 0:0.033078:0.165390; %m contrast up 
contrastValues(4,:) = 0.165390:-0.033078:0; %m contrast down
contrastValues(5,:) = 0:0.179616:0.898080; %s contrast up
contrastValues(6,:) = 0.898080:-0.179616:0; %s contrast down

%convert contrast values to RGB values and store in 3D matrix
mondrianColors = zeros(6,6,3);
mondrianColors(:,:,1) = contrastValues; 
for i = 1:6
    for j = 1:6
        switch i 
            case {1, 2} %l cone
                mondrianColors(i,j,:) = contrastTorgb([mondrianColors(i,j,1) 0 0], [0.5 0.5 0.5], cal);               
            case {3, 4} %m cone
                mondrianColors(i,j,:) = contrastTorgb([0 mondrianColors(i,j,1) 0], [0.5 0.5 0.5], cal);
            case {5, 6} %s cone 
                mondrianColors(i,j,:) = contrastTorgb([0 0 mondrianColors(i,j,1)], [0.5 0.5 0.5], cal); 
        end
        mondrianColors(i,j,:) = PrimaryToSettings(cal,mondrianColors(i,j,:));  %gamma correction 
    end 
end

%create and open window 
win = GLWindow('BackgroundColor', [0 0 0], 'SceneDimensions', size);
win.addMondrian(6, 6, size, mondrianColors);
win.open;

%set up character listening
ListenChar(2);
FlushEvents;

%continue drawing until the user presses a key 
while ~CharAvail
    win.draw;
end 
ListenChar(0); 
win.close; 
    
end