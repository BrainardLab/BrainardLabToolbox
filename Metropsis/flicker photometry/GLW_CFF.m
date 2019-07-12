function GLW_CFF(fName, varargin)
% Heterochromatic flicker photometry experiment using GLWindow
%
% Syntax:
%   GLW_CFF
%
% Description:
%    Implements a heterochromatic flicker photometry experiment using
%    GLWindow. Subjects see a red and green light flickering at 30Hz and
%    use keypresses to adjust the m cone contrast to minimize the flicker 
%    (u = adjust up, d = adjust down, q = quit adjustment). The program 
%    saves subjects' adjustment history and displays their chosen m cone
%    contrast and adjustments on the screen. It is designed for displays  
%    with 60 or 120 Hz frame rates and includes code for verifying timing.
%
% Inputs (optional)
%    fName             - Matlab string ending in .mat. Indicates name of
%                        file you want to create/save data to. Default is
%                        'CFFresults.mat'
%
% Outputs:
%    none
%
% Optional key/value pairs (can only use if you input a filename):
%    'viewDistance'   - double indicating viewing distance in mm. Default
%                       is 400
%
%    'maxFrames'      - double indicating the maximum number of frames,
%                       mostly used for timing verification. Default is Inf
%
%    'calFile'        - string with name of calibration file. Default is 
%                       'MetropsisCalibration' 

%History:
%    06/05/19  dce       Wrote it. Visual angle conversion code from ar
%                        ('ImageSizeFromAngle.m')
%    06/06/19  dce       Minor edits, input error checking
%    06/13/19  dce       Added code to verify timing/find missed frames
%    06/21/19  dce       Added calibration routine
%    06/27/19  dce       Modified user adjustment process to avoid skipped
%                        frames
%    07/10/19  dce       Rewrote stimuli to be in terms of cone contrast 
%                        values rather than rgb values. 

% Examples:
%{
    GLW_CFF
    GLW_CFF('Deena.mat')
    GLW_CFF('Deena.mat', 'viewDistance', 1000)
    GLW_CFF('Deena.mat', 'maxFrames', 3600)
    GLW_CFF('Deena.mat', 'calFile', 'MetropsisCalibration')
%}

%parse input
if nargin == 0
    fName = 'CFFresults.mat'; %default filename
elseif nargin > 7
    error('too many inputs');
end
p = inputParser;
p.addParameter('viewDistance', 400, @(x) (isnumeric(x) & isscalar(x)));
p.addParameter('maxFrames', Inf, @(x) (isnumeric(x) & isscalar(x)));
p.addParameter('calFile', 'MetropsisCalibration', @(x) (isstring(x))); 
p.parse(varargin{:});

%get information on display
disp = mglDescribeDisplays;
last = disp(end); %we will be using the last display
frameRate = last.refreshRate;
screenSize = last.screenSizeMM; %screen dimensions in mm
height = screenSize(2) / 2;

%load calibration information
[cal,cals] = LoadCalFile(p.Results.calFile,[],getpref('BrainardLabToolbox','CalDataFolder'));
load T_cones_ss2 %cone fundamentals
cal = SetSensorColorSpace(cal,T_cones_ss2, S_cones_ss2);
cal = SetGammaMethod(cal,0);

%fill table with m contrast values. Contrast values go from 0 to 16.5757%
% (max contrast on the Metropsis display for the given background)
mArray = zeros(3,20);
mArray(2,:) = 0.00828785:0.00828785:0.165757; 

%convert contrast values to RGB values 
for i = 1:20
    mArray(:,i) = contrastTorgb(cal, mArray(:,i), 'RGB', true); 
end
mPosition = 1; %initial position in table of values

%create array to store adjustment history
adjustmentArray = zeros(3,100);
adjustmentArrayPosition = 2; %initial position in adjustment history array

try
    %instructions window
    intro = GLWindow('BackgroundColor', [0 0 0], 'SceneDimensions',...
        screenSize, 'windowID', length(disp));
    intro.addText('A flashing red and green circle will appear on the screen',...
        'Center', [0 0.3 * height], 'FontSize', 75, 'Color', [1 1 1],...
        'Name', 'line1');
    intro.addText('Try to adjust the green light to minimize the flicker',...
        'Center', [0 0.1 * height], 'FontSize', 75, 'Color', [1 1 1],...
        'Name', 'line2');
    intro.addText('Press u to increase green intensity and press d to decrease green intensity',...
        'Center', [0 -0.1 * height], 'FontSize', 75, 'Color', [1 1 1],...
        'Name', 'line3');
    intro.addText('When you are done, press q to quit adjustment',...
        'Center', [0 -0.3 * height], 'FontSize', 75, 'Color', [1 1 1],...
        'Name', 'line4');
    intro.open;
    mglDisplayCursor(0);
    
    duration = 8; %duration that instructions appear (s)
    for i = 1:(frameRate * duration)
        intro.draw;
    end
    intro.close;
    
    %create stimulus window
    win = GLWindow('BackgroundColor', [0.5 0.5 0.5],...
        'SceneDimensions', screenSize, 'windowID', length(disp));
    
    %calculate color of circle and diameter in mm. Then add circle. 
    %lCone color is set to 10% l contrast
    lCone = contrastTorgb(cal, [0.154933 0 0], 'RGB', true); 
    angle = 2; %visual angle (degrees)
    diameter = tan(deg2rad(angle/2)) * (2 * p.Results.viewDistance); 
    win.addOval([0 0], [diameter diameter], lCone, 'Name', 'circle');
    
    %enable character listening
    win.open;
    mglDisplayCursor(0);
    ListenChar(2);
    FlushEvents;
    
    %initial parameters 
    trackLCone = true; %stimulus color tracker
    elapsedFrames = 1;
    maxFrames = p.Results.maxFrames;
    if isfinite(maxFrames)
        timeStamps = zeros(1,maxFrames);
    end
    
    %loop to swich oval color and parse user input
    while elapsedFrames <= maxFrames
        %draw circle
        if trackLCone
            color = lCone;
        else
            color = mArray(:,mPosition)';
        end
        win.setObjectColor('circle', color);
        win.draw;
        
        %save timestamp
        if isfinite(maxFrames)
            timeStamps(elapsedFrames) = mglGetSecs;
        end
        elapsedFrames = elapsedFrames + 1;
        
        %switch color if needed
        if (frameRate == 120 && mod(elapsedFrames, 2) == 1) || frameRate == 60 
            trackLCone = ~trackLCone;
        end
        
        %check for user input
        if CharAvail
            switch GetChar
                case 'q' %quit adjustment
                    break;
                case 'u' %adjust green up
                    mPosition = mPosition + 1;
                    if mPosition > 20 
                        mPosition = 20;
                    end
                case 'd' %adjust green down
                    mPosition = mPosition - 1;
                    if mPosition < 1 
                        mPosition = 1;
                    end
            end
            %store new m value in adjustment history table 
            adjustmentArray(:,adjustmentArrayPosition) = mArray(:,mPosition);
            adjustmentArrayPosition = adjustmentArrayPosition + 1; 
        end
    end
    
    %clean up once user finishes
    ListenChar(0);
    mglDisplayCursor(1);
    win.close;
    
    if isfinite(maxFrames)
        %plot frame durations 
        timeSteps = diff(timeStamps);
        figure(1);
        plot(timeSteps, 'r'); %actual frame durations 
        yline(1/frameRate, 'b'); %target frame rate 
        yline(2/frameRate, 'g'); %double target frame rate
        yline(0,'g'); %0 time 
        axis([0 maxFrames 0 2.5/frameRate]);
        title('Frame Rate');
        xlabel('Frame');
        ylabel('Duration (s)');
        legend('Measured Frame Rate', 'Target Frame Rate', 'Skipped Frame');
        
        %plot deviations from target frame rate
        figure(2);
        deviation = timeSteps - (1/frameRate); 
        plot(deviation, 'r');
        axis([0 maxFrames -2/frameRate 2/frameRate]);
        title('Deviations from Frame Rate');
        xlabel('Frame');
        ylabel('Difference Between Measured and Target Duration (s)');
    end
    
    %reformat adjustment history array  
    adjustmentArray = adjustmentArray(adjustmentArray ~= 0); 
    col = length(adjustmentArray)/3;
    adjustmentArray = reshape(adjustmentArray, [3 col]);
    for i = 1:col
        adjustmentArray(:,i) = SettingsToSensor(cal, adjustmentArray(:,i)); 
    end 
    adjustmentArray = adjustmentArray(2,:); 
    
    fprintf('chosen m cone contrast is %g \n', adjustmentArray(end));
    fprintf('adjustment history: ');
    fprintf('%g, ', adjustmentArray); 
    fprintf('\n'); 
    save(fName, 'adjustmentArray');
catch e %handle errors
    ListenChar(0);
    mglDisplayCursor(1);
    rethrow(e);
end
end
