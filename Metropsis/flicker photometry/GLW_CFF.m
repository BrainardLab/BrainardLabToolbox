function GLW_CFF(fName, varargin)
% Heterochromatic flicker photometry experiment using GLWindow
%
% Syntax:
%   GLW_CFF
%
% Description:
%    Implements a heterochromatic flicker photometry experiment using
%    GLWindow. Subjects see a red and green light flickering at 30Hz and
%    use keypresses to adjust the intensity of the green light to minimize
%    the flicker (u = adjust up, d = adjust down, q = quit adjustment). The
%    program saves subjects' adjustment history and displays their chosen
%    intensity and adjustments on the screen. It is designed for displays
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
%                       is 400.
%
%    'maxFrames'      - double indicating the maximum number of frames,
%                       mostly used for timing verification. Default is Inf

%History:
%    06/05/19  dce       Wrote it. Visual angle conversion code from ar
%                        ('ImageSizeFromAngle.m')
%    06/06/19  dce       Minor edits, input error checking
%    06/13/19  dce       Added code to verify timing/find missed frames
%    06/21/19  dce       Added calibration routine
%    06/27/19  dce       Modified user adjustment process to avoid skipped
%                        frames

% Examples:
%{
    GLW_CFF
    GLW_CFF('Deena.mat')
    GLW_CFF('Deena.mat', 'viewDistance', 1000)
    GLW_CFF('Deena.mat', 'maxFrames', 3600)
%}

%parse input
if nargin == 0
    fName = 'CFFresults.mat'; %default filename
elseif nargin > 5
    error('too many inputs');
end
p = inputParser;
p.addParameter('viewDistance', 400, @(x) (isnumeric(x) & isscalar(x)));
p.addParameter('maxFrames', Inf, @(x) (isnumeric(x) & isscalar(x)));
p.parse(varargin{:});

%get information on display
disp = mglDescribeDisplays;
last = disp(end); %we will be using the last display
frameRate = last.refreshRate;
screenSize = last.screenSizeMM; %screen dimensions in mm
height = screenSize(2) / 2;

%load calibration information
[cal,cals] = LoadCalFile('MetropsisCalibration',[],...
    getpref('BrainardLabToolbox','CalDataFolder'));
load T_cones_ss2 %cone fundamentals
cal = SetSensorColorSpace(cal,T_cones_ss2, S_cones_ss2);
cal = SetGammaMethod(cal,0);

%calculate table of green RGB values
greenArray = zeros(3,21);
greenArray(1,:) = 0.128;
greenArray(2,:) = 0.1009:0.001375:0.1284;
greenArray(3,:) = 0.03;
for i = 1:21
    greenArray(:,i) = SensorToSettings(cal, greenArray(:,i));
end
greenPosition = 1; %initial position in table of values 

%create array to store adjustment history
adjustmentArray = zeros(3,100);
adjustmentArray(:,1) = greenArray(:,1); 
adjustmentArrayPosition = 2;

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
    backgroundColor = [0.5 0.5 0.5]; %should this be switched to lms?
    win = GLWindow('BackgroundColor', backgroundColor, 'SceneDimensions',...
        screenSize, 'windowID', length(disp));
    
    %calculate color of circle and diameter in mm. Then add circle. 
    %red color stimulates l cones 3 times as much as m cones
    red = SensorToSettings(cal, [0.04235 0.0140 0.0011]')'; 
    angle = 2; %visual angle (degrees)
    diameter = tan(deg2rad(angle/2)) * (2 * p.Results.viewDistance); 
    win.addOval([0 0], [diameter diameter], red, 'Name', 'circle');
    
    %enable character listening
    win.open;
    mglDisplayCursor(0);
    ListenChar(2);
    FlushEvents;
    
    %initial parameters 
    trackRed = true; %stimulus color tracker
    elapsedFrames = 1;
    maxFrames = p.Results.maxFrames;
    if isfinite(maxFrames)
        timeStamps = zeros(1,maxFrames);
    end
    
    %loop to swich oval color and parse user input
    while elapsedFrames <= maxFrames
        %draw circle
        if trackRed
            color = red;
        else
            color = greenArray(:,greenPosition)';
        end
        win.setObjectColor('circle', color);
        win.draw;
        
        %save timestamp
        if isfinite(maxFrames)
            timeStamps(elapsedFrames) = mglGetSecs;
        end
        
        elapsedFrames = elapsedFrames + 1;
        %switch color if needed
        if (frameRate == 120 && mod(elapsedFrames, 2) == 1)...
                || frameRate == 60
            trackRed = ~trackRed;
        end
        
        %check for user input
        if CharAvail
            switch GetChar
                case 'q' %quit adjustment
                    break;
                case 'u' %adjust green up
                    greenPosition = greenPosition + 1;
                    if greenPosition > 21 %20 steps
                        greenPosition = 21;
                    end
                case 'd' %adjust green down
                    greenPosition = greenPosition - 1;
                    if greenPosition < 1 %20 steps
                        greenPosition = 1;
                    end
            end
            adjustmentArray(:,adjustmentArrayPosition)...
                = greenArray(:,greenPosition);
            adjustmentArrayPosition = adjustmentArrayPosition + 1; 
        end
    end
    
    %clean up once user finishes
    ListenChar(0);
    mglDisplayCursor(1);
    win.close;
    
    %plot timing results
    if isfinite(maxFrames)
        timeSteps = diff(timeStamps);
        save('timeSteps','timeSteps');
        figure(1);
        plot(timeSteps, 'r');
        yline(1/frameRate, 'b');
        yline(2/frameRate, 'g');
        yline(0,'g');
        axis([0 maxFrames 0 2.5/frameRate]);
        title('Frame Rate');
        xlabel('Frame');
        ylabel('Duration (s)');
        legend('Measured Frame Rate', 'Target Frame Rate',...
            'Skipped Frame');
        
        figure(2);
        deviation = timeSteps - (1/frameRate);
        plot(deviation, 'r');
        axis([0 maxFrames -2/frameRate 2/frameRate]);
        title('Deviations from Frame Rate');
        xlabel('Frame');
        ylabel('Difference Between Measured and Target Duration (s)');
    end
    
    %format adjustment history array  
    adjustmentArray = adjustmentArray(adjustmentArray ~= 0); 
    col = length(adjustmentArray)/3;
    adjustmentArray = reshape(adjustmentArray, [3 col]);
    for i = 1:col
        adjustmentArray(:,i) = SettingsToSensor(cal, adjustmentArray(:,i)); 
    end 
    adjustmentArray = adjustmentArray(2,:); 
    
    fprintf('chosen intensity of m cone is %g \n', adjustmentArray(end));
    fprintf('adjustment history: ');
    fprintf('%g, ', adjustmentArray); 
    fprintf('\n'); 
    save(fName, 'adjustmentArray');
    
catch e %handle errors
    ListenChar(0);
    mglDisplayCursor(1);
    if ~isempty(win)
        win.close;
    end
    rethrow(e);
end
end
