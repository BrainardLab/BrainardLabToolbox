function GLW_CFF(fName, varargin)
% Heterochromatic flicker photometry experiment using GLWindow. This
% version only lets subjects respond in between stimulus presentations
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

% Examples:
%{
    GLW_CFF
    GLW_CFF('Deena.mat')
    GLW_CFF('Deena.mat', 'viewDistance', 1000) %1 meter viewing distance
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
    win = GLWindow('BackgroundColor', [0.5 0.5 0.5], 'SceneDimensions',...
        size, 'windowID', length(disp));
    
    %calculate diameter of circle in mm and add circle
    angle = 2; %visual angle (degrees)
    diameter = tan(deg2rad(angle/2)) * (2 * p.Results.viewDistance);
    win.addOval([0 0], [diameter diameter], [1 0 0], 'Name', 'circle');
    
    %enable character listening
    win.open;
    mglDisplayCursor(0);
    
    count = 1; %frame counter
    responseCounter = 1; %used to keep drawing response patch
    red = true; %oval color tracker
    g = 0.05; %initial green intensity
    g_values = [0.05]; %vector to store subject's adjustment values
    
    %timing check parameters
    maxFrames = p.Results.maxFrames;
    elapsedFrames = 1;
    if isfinite(maxFrames)
        timeStamps = zeros(1,maxFrames);
    end
    
    %loop to swich oval color and parse user input
    while elapsedFrames <= maxFrames
        
        %draw circle
        if (mod(elapsedFrames,3 * frameRate) == 0)
            color = [0.5 0.5 0.5];
            responseCounter = 1;
        elseif responseCounter <= frameRate && elapsedFrames > frameRate
            color = [0.5 0.5 0.5];
        elseif red
            color = [1 0 0];
        else
            color = [0 g 0];
        end
        win.setObjectColor('circle', color);
        win.draw;
        
        %save timestamp
        if isfinite(maxFrames)
            timeStamps(elapsedFrames) = mglGetSecs;
        end
        
        %switch color if needed
        count = count + 1;
        if (frameRate == 120 && count == 3) || frameRate == 60
            red = ~red;
            count = 1;
        end
        
        %check for user input
        if color == [0.5 0.5 0.5]
            ListenChar(2);
            FlushEvents;
            if CharAvail
                switch GetChar
                    case 'q' %quit adjustment
                        ListenChar(0);
                        break;
                    case 'u' %adjust green up
                        g = g + 0.05;
                        if g > 1
                            g = 1;
                        end
                        g_values = [g_values, g];
                    case 'd' %adjust green down
                        g = g - 0.05;
                        if g < 0
                            g = 0;
                        end
                        g_values = [g_values, g];
                end
            end
            ListenChar(0);
        end
        elapsedFrames = elapsedFrames + 1;
        responseCounter = responseCounter + 1;
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
    fprintf('chosen intensity of green is %g \n', g);
    fprintf('adjustment history: g = ');
    fprintf('%g ', g_values);
    fprintf('\n');
    save(fName, 'g_values');
    
catch e %handle errors
    mglDisplayCursor(1);
    if ~isempty(win)
        win.close;
    end
    rethrow(e);
end
end
