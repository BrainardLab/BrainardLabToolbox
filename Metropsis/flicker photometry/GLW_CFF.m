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

% Examples:
%{
    GLW_CFF
    GLW_CFF('Deena.mat')
    GLW_CFF('Deena.mat', 'viewDistance', 1000)
    GLW_CFF('Deena.mat', 'maxFrames', 3600)
%}

%load calibration information 
[cal,cals] = LoadCalFile('MetropsisCalibration',[],getpref('BrainardLabToolbox','CalDataFolder'));
load T_cones_ss2 %cone fundamentals 
cal = SetSensorColorSpace(cal,T_cones_ss2, S_cones_ss2);
cal = SetGammaMethod(cal,0);

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
size = last.screenSizeMM; %scale window based on screen dimensions in mm
height = size(2) / 2;

try
    %instructions window
    intro = GLWindow('BackgroundColor', [0 0 0], 'SceneDimensions',...
        size, 'windowID', length(disp));
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
    backgroundColor = [0.5 0.5 0.5]; %should this stay in rgb? 
    win = GLWindow('BackgroundColor', backgroundColor, 'SceneDimensions',...
        size, 'windowID', length(disp));
    
    %calculate diameter of circle in mm and add circle
    angle = 2; %visual angle (degrees)
    diameter = tan(deg2rad(angle/2)) * (2 * p.Results.viewDistance);
    redColor = SensorToSettings(cal, [0.04235 0.0140 0.0011]')'; %stimulates l cones 3 times as much as m cones
    win.addOval([0 0], [diameter diameter], redColor, 'Name', 'circle');
    
    %enable character listening
    win.open; 
    mglDisplayCursor(0); 
    ListenChar(2);
    FlushEvents;
    
    count = 1; %frame counter to delay color change for 120Hz display
    red = true; %oval color tracker
    m = 0.1009; %initial m cone intensity
    m_values = [0.1009]; %vector to store subject's adjustment values
    
    %timing check parameters
    maxFrames = p.Results.maxFrames;
    elapsedFrames = 1; 
    if isfinite(maxFrames)
        timeStamps = zeros(1,maxFrames); 
    end
    
    %loop to swich oval color and parse user input
    while elapsedFrames <= maxFrames
        %draw circle
        if red
            color = redColor;
        else
            color = SensorToSettings(cal, [0.128 m 0.03]')';
        end
        win.setObjectColor('circle', color);
        win.draw;
        
        %save timestamp
        if isfinite(maxFrames) 
            timeStamps(elapsedFrames) = mglGetSecs;
            elapsedFrames = elapsedFrames + 1;
        end 
        
        %switch color if needed
        count = count + 1;
        if (frameRate == 120 && count == 3) || frameRate == 60
            red = ~red;
            count = 1;
        end
        
        %check for user input
        if CharAvail 
            switch GetChar
                case 'q' %quit adjustment
                    break;
                case 'u' %adjust green up
                    m = m + 0.001375; %allow 20 steps
                    if m > 0.1284
                        m = 0.1284;
                    end
                    m_values = [m_values, m];
                case 'd' %adjust green down
                    m = m - 0.001375;
                    if m < 0.1009
                        m = 0.1009;
                    end
                    m_values = [m_values, m];
            end
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
    
    %display results
    fprintf('chosen intensity of green is %g \n', m);
    fprintf('adjustment history: m = ');
    fprintf('%g ', m_values);
    fprintf('\n');
    save(fName, 'm_values');
    
catch e %handle errors
    ListenChar(0);
    mglDisplayCursor(1); 
    if ~isempty(win)
        win.close;
    end
    rethrow(e);
end
end
