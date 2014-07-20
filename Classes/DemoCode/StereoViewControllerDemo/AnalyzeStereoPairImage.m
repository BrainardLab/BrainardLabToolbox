function AnalyzeStereoPairImage
% Function to analyze a stereo pair of images in order to compute the real world
% X,Y,Z coordinates of different scene features.
%
% 5/1/2013  npc   Wrote it
% 5/2/2012  npc   Added export-to-EPS, options to show/hide vergence rays
%                 Added quads mapping
%
    clear all; clear global;

    % Default image directory
    global imageDirectory
    imageDirectory = '.';
    
    % Set 3D parameters
    Set3Dparams();
    
    % Define palette of colors for different points/quads
    global PointsColors
    PointsColors = [1 0 0; ...
                    0 1 0; ...
                    0 0 1; ...
                    1 0 1; ...
                    0 0.5 1; ...
                    1 0.6 0; ...
                    1.0 0.85 0.85; ...
                    0.5 0.2 0.7];

    % Create the GUI
    CreateGUI;
    
    % Initialize lists of points and quads
    EmptyListOfMatchingPoints();

end


% Method that generates the GUI and sets the callbacks for the various elements    
function CreateGUI
%    
    global GUI
    
    % Generate GUI struct
    GUI = struct;
    GUI.figHandle = figure(1); clf;
    
    set(GUI.figHandle, 'NumberTitle', 'off','Visible','off',...
               'MenuBar','None', 'Position',[360,500,1580,1040]);
    
    % Create left image plot axes
    GUI.leftImageHandle = axes('Units','pixels','Position',[70,560,640,400]);
    
    % Create right image plot axes
    GUI.rightImageHandle = axes('Units','pixels','Position',[70,70,640,400]);
    
    % Initialize image plots
    InitializeImagePlots();
    
     % Create the X-Z top view plot
    GUI.XZplotHandle = axes('Units','pixels','Position',[900,70, 600, 890]);
    UpdateRealWorldCoordsPlot('on');
    
    % Create the options checkboxes
    global drawRaysOption
    global drawScreenCoordsOption
    
    drawRaysOption = false;
    drawScreenCoordsOption = false;
    
    GUI.drawRaysToggle = uicontrol('Style','checkbox','String','Draw Rays',...
                'Value',drawRaysOption, 'Position', [1350 990 130 20], ...
                'Callback',{@ToggleFlag_Callback});
            
    GUI.drawScreenCoordsToggle = uicontrol('Style','checkbox','String','Draw Screen Coords',...
                'Value', drawScreenCoordsOption, 'Position', [1350 970 130 20], ...
                'Callback',{@ToggleFlag_Callback});
                                                       
    % Create the New Left Image button
    newLeftImageButton = uicontrol( 'Style','pushbutton','String','Update Left Screen Image',...
                                'Position', [270, 970, 230,40], ...
                                'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@UpdateScreenImage_Callback});
                            
    % Create the New Right Image button
    newRightImageButton = uicontrol( 'Style','pushbutton','String','Update Right Screen Image',...
                                'Position', [270, 480, 230,40], ...
                                'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@UpdateScreenImage_Callback});
                           
    % Create the Export button
    exportButton = uicontrol( 'Style','pushbutton','String','Export to EPS',...
                                'Position', [740, 740,130,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@Export_Callback});
          
    % Create the RRemove all button
    restartButton = uicontrol( 'Style','pushbutton','String','Remove all',...
                                'Position', [740, 420,130,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@Restart_Callback});
                            
    % Create the New Quad button
    newQuadButton = uicontrol( 'Style','pushbutton','String','New (L,R) quad',...
                                'Position', [740, 360,130,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@NewQuad_Callback});
                                 
    % Create the New (L,R) Point button
    newPointButton = uicontrol( 'Style','pushbutton','String','New (L,R) point',...
                                'Position', [740, 300,130,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Callback',{@NewPoint_Callback});
                           
    % Create the text boxes that display the coords of left and right points
    GUI.leftImagePointHandle  = uicontrol('Style','edit','String','', 'Enable', 'off', ...
                                'Position',[740, 260, 130, 30], 'FontName', 'Helvetica', 'FontSize', 16);
    GUI.rightImagePointHandle = uicontrol('Style','edit','String','',  'Enable', 'off', ...
                                'Position',[740, 230, 130, 30], 'FontName', 'Helvetica', 'FontSize', 16);
    
    % Create the 3D coords button (inactive)
    virtual3DButton = uicontrol( 'Style','pushbutton','String','3DPoint Coords',...
                                'Position', [740, 160,130,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                                'Enable', 'off');
                           
    % Create the text boxes that display the real-world coordinates of the virtual 3D point
    GUI.virtual3DPointXcoordHandle = ...
                    uicontrol('Style','edit','String','', 'Enable', 'off', ...
                               'Position',[740, 130, 130, 30], 'FontName', 'Helvetica', 'FontSize', 16);
    GUI.virtual3DPointYcoordHandle = ...
                    uicontrol('Style','edit','String','', 'Enable', 'off', ...
                              'Position',[740, 100, 130, 30], 'FontName', 'Helvetica', 'FontSize', 16);
    GUI.virtual3DPointZcoordHandle = ...
                    uicontrol('Style','edit','String','', 'Enable', 'off', ...
                              'Position',[740, 70, 130, 30], 'FontName', 'Helvetica', 'FontSize', 16);
                                                                                
    % Create the Track XZpoint toggle button
    dataCursorModeButton = ...
                    uicontrol( 'Style','togglebutton','String','Data Cursor Mode',...
                               'Position', [1125, 970,150,40], 'FontName', 'Helvetica', 'FontSize', 16, ...
                               'Callback',{@TrackDataPoints_Callback});
                            
    % Make the GUI background white-ish
    set(GUI.figHandle, 'Color', [0.9 0.9 0.9]);
    
    % Assign the GUI a name which will appear in the window title.
    set(GUI.figHandle, 'Name', 'Stereo Pair Image Depth Analyzer');
  
    % Move the GUI to the center of the screen.
    movegui(GUI.figHandle, 'center');
  
    % Set the mouse motion detector
    % set(GUI.figHandle,'windowbuttonmotionfcn', 'Callback', @MouseMotion_Callback); 
    
    % Set the data cursor mode object and its handle
    GUI.dataCursorModeObject = datacursormode(GUI.figHandle);
    set(GUI.dataCursorModeObject, 'UpdateFcn', @ReportDataPoints_Callback);
    set(GUI.dataCursorModeObject, 'DisplayStyle','datatip');
    set(GUI.dataCursorModeObject, 'enable', 'off') ;   
    
    % Make the GUI visible.
    set(GUI.figHandle, 'Visible','on');
end
    


% Method that erases the lists of selected points and quads
function EmptyListOfMatchingPoints()
    global leftImageSamples
    global rightImageSamples
    global leftImageQuads
    global rightImageQuads
    global quadsNum
    
    leftImageSamples = [];
    rightImageSamples = [];
    
    leftImageQuads = [];
    rightImageQuads = [];
    quadsNum = 0;
    
    % Make sure the XZ plot will not retain old points
    UpdateRealWorldCoordsPlot('off');
end

% Method that sets the 3D parameters of out scene
function Set3Dparams()
    global virtualSceneWidthInCm
    global virtualSceneHeightInCm
    global virtualSceneDistanceFromObserverInCm
    global interPupilarySeparationInCm
    
    virtualSceneWidthInCm                   = 51.7988;
    virtualSceneHeightInCm                  = 32.3618;
    virtualSceneDistanceFromObserverInCm    = 76.4;  
    interPupilarySeparationInCm             = 6.4;   
end

% Method to initialize the left/right image plots
function InitializeImagePlots()
    global GUI
    global xaxis
    global yaxis
    global zaxis
    global virtualSceneWidthInCm
    global virtualSceneHeightInCm
    
    xaxis = ([1:1920]-1920/2)/(1920/2)*virtualSceneWidthInCm;
    yaxis = ([1:1200]-1200/2)/(1200/2)*virtualSceneHeightInCm;
    zaxis = [0:120];
    
    set(GUI.leftImageHandle, 'FontName', 'Helvetica', 'FontSize', 16);
    set(GUI.leftImageHandle, 'XLim', [xaxis(1) xaxis(end)], 'YLim', [yaxis(1) yaxis(end)], 'XColor', 'b', 'YColor', 'b');
    box(GUI.leftImageHandle, 'on')
    ylabel(GUI.leftImageHandle, 'LCD display y-coord (cm)');
    
    set(GUI.rightImageHandle, 'FontName', 'Helvetica', 'FontSize', 16);
    set(GUI.rightImageHandle, 'XLim', [xaxis(1) xaxis(end)], 'YLim', [yaxis(1) yaxis(end)], 'XColor', 'b', 'YColor', 'b');
    box(GUI.rightImageHandle, 'on')
    xlabel(GUI.rightImageHandle, 'LCD display x-coord (cm)');
    ylabel(GUI.rightImageHandle, 'LCD display y-coord (cm)');
end


% Method to update the left/right image plot
function UpdateImagePlots(whichScreen)
    global GUI
    global leftImageData
    global rightImageData
    global xaxis
    global yaxis
    global zaxis
    global virtualSceneWidthInCm
    global virtualSceneHeightInCm
 
    % get the appropriate image data for the displayed screen
    if strcmpi(whichScreen, 'left')
       imageData = leftImageData;
    else
       imageData = rightImageData;
    end
    
    % Get image size
    imageWidthInPixels  = size(imageData,2);
    imageHeightInPixels = size(imageData,1);
    
    % ReGenerate image axes
    xaxis = ([1:imageWidthInPixels]-imageWidthInPixels/2)/(imageWidthInPixels/2)*virtualSceneWidthInCm;
    yaxis = ([1:imageHeightInPixels]-imageHeightInPixels/2)/(imageHeightInPixels/2)*virtualSceneHeightInCm;
    
    % box(GUI.leftImageHandle, 'off')
    % box(GUI.rightImageHandle, 'off')
    
    if strcmpi(whichScreen, 'left')
        box(GUI.leftImageHandle, 'off');
        imagesc(xaxis, yaxis, imageData, 'Parent', GUI.leftImageHandle);
        set(GUI.leftImageHandle, 'XLim', [xaxis(1) xaxis(end)], 'YLim', [yaxis(1) yaxis(end)], 'XColor', 'b', 'YColor', 'b');
        axis(GUI.leftImageHandle, 'xy');
        box(GUI.leftImageHandle, 'on');
        ylabel(GUI.leftImageHandle, 'LCD display y-coord (cm)');
    else
        box(GUI.rightImageHandle, 'off');
        imagesc(xaxis, yaxis, imageData, 'Parent', GUI.rightImageHandle); 
        set(GUI.rightImageHandle, 'XLim', [xaxis(1) xaxis(end)], 'YLim', [yaxis(1) yaxis(end)], 'XColor', 'b', 'YColor', 'b');
        axis(GUI.rightImageHandle, 'xy');
        box(GUI.rightImageHandle, 'on');
        xlabel(GUI.rightImageHandle, 'LCD display x-coord (cm)');
        ylabel(GUI.rightImageHandle, 'LCD display y-coord (cm)');
    end
end


% Method to toggle the various flags depending on the state of the source checkbox element
function ToggleFlag_Callback(source, varargin)
    global GUI
    global drawRaysOption
    global drawScreenCoordsOption
    
    if (source == GUI.drawRaysToggle)
        drawRaysOption = ~drawRaysOption;
    elseif (source == GUI.drawScreenCoordsToggle)
        drawScreenCoordsOption = ~drawScreenCoordsOption;
    end
    
    UpdateRealWorldCoordsPlot('off');
end


% Method that responds to mouse motion events
function MouseMotion_Callback(varargin)
    global GUI
    mouseCoords = get(GUI.figHandle,'currentpoint');  % The current point w.r.t the figure.
end


% Method that sets the data cursor model object depending on the state of the source toggle button
function TrackDataPoints_Callback(source, varargin)
    global GUI
    
    if (get(source, 'Value') == 1)
        % enable data cursor mode
        set(GUI.dataCursorModeObject, 'enable', 'on');
    else
        % disable data cursor mode use
        set(GUI.dataCursorModeObject, 'enable', 'off');
    end
end


% Method that reports the (x,y) coords of the point under the mouse when in
% data cursor mode
function dataString = ReportDataPoints_Callback(~, eventdata)
    global GUI
    
    % Get the data points
    pos = get(eventdata,'Position');
    
    % determine which string to return depending on the current axes
    if (gca == GUI.XZplotHandle)
        dataString = {['X: ',num2str(pos(1),4)],['Z: ',num2str(pos(2),4)]};
    else
        dataString = {['X: ',num2str(pos(1),4)],['Y: ',num2str(pos(2),4)]};
    end
end


% Method that erases all selected points and quads and resets the graphics
function Restart_Callback(varargin)
    EmptyListOfMatchingPoints();
    UpdateImagePlots('left');
    UpdateImagePlots('right');
end


% Method called when the user presses the Export to EPS button.
% This method exports the current state of the GUI into an encapsulated
% postsctipt file.
function Export_Callback(varargin)
    global imageDirectory
    
    % Prompt the user where to save the EPS file
    [imageFileName, imageDirectory] = uiputfile('*.eps','EPS filename', imageDirectory);

    if (imageDirectory == 0)
        imageDirectory = '.';
        return;
    end
        
    global GUI
    set(GUI.figHandle,'PaperPositionMode','auto');
    set(GUI.figHandle,'InvertHardcopy','off');
    print(GUI.figHandle,'-depsc',fullfile(imageDirectory, imageFileName));
end


% Method called when the user presses the Update Left/Right Screen Image
% button. This methods prompts the user to enter a TIFF input file, loads
% the data from the file, and calls the UpdateImagePlots method to plot the
% loaded image data.
function UpdateScreenImage_Callback(source, varargin)
   global leftImageData
   global rightImageData
   global imageDirectory
   
   % Determine the selected data set.
   if (strcmpi(get(source, 'String'), 'Update Left Screen Image'))
       % Load the left image file
        [imageFileName, imageDirectory] = uigetfile('*.tif','Select LEFT SCREEN image file', imageDirectory);
        if (imageDirectory == 0)
            imageDirectory = '.';
            return;
        end
        leftImageData = imread(fullfile(imageDirectory, imageFileName));
        for RGB = 1:3
            r = leftImageData(:,:,RGB);
            r = flipud(r);
            leftImageData(:,:,RGB) = r;
        end
        UpdateImagePlots('left');
   end
   
   if (strcmpi(get(source, 'String'), 'Update Right Screen Image'))
       % Load the right image file     
        [imageFileName, imageDirectory] = uigetfile('*.tif','Select RIGHT SCREEN image file', imageDirectory);
        if (imageDirectory == 0)
            imageDirectory = '.';
            return;
        end
        rightImageData = imread(fullfile(imageDirectory, imageFileName));
        for RGB = 1:3
            r = rightImageData(:,:,RGB);
            r = flipud(r);
            rightImageData(:,:,RGB) = r;
        end
        UpdateImagePlots('right');
   end
end


% Method called when the user presses the New (R,L) quad button. The method
% presents a cross-hair with which the user has to select a pair of quadruplets of
% points: one for the left image and a corresponding one for the right
% image.
function NewQuad_Callback(varargin)
    global GUI
    global leftImageQuads
    global rightImageQuads
    global quadsNum
    global PointsColors
    
    axes(GUI.leftImageHandle);
    
    quadsNum = quadsNum + 1;
    % Select color
    color = squeeze(PointsColors(mod(quadsNum -1,8)+1, :));
    
    for screen = 1:2
        % Get 4 input points from each screen
        [x,y] = ginput(4);
        if (gca == GUI.leftImageHandle) 
            % close the rectangle
            x(5) = x(1); y(5) = y(1);
            
            % store the quad
            leftImageQuads(quadsNum,:,:) = reshape([x,y], [1 5 2]);

            % plot point on top of the left image
            hold(GUI.leftImageHandle, 'on');
            plot(GUI.leftImageHandle, leftImageQuads(quadsNum,:,1), leftImageQuads(quadsNum,:,2), 'k.', 'MarkerEdgeColor', color, 'MarkerSize', 10);
            plot(GUI.leftImageHandle, leftImageQuads(quadsNum,:,1), leftImageQuads(quadsNum,:,2), 'k-', 'Color', color); 
        
        elseif (gca == GUI.rightImageHandle)
            % close the rectangle
            x(5) = x(1); y(5) = y(1);
            rightImageQuads(quadsNum,:,:) = reshape([x,y], [1 5 2]);
            
            % plot point on top of the right image
            hold(GUI.rightImageHandle, 'on');
            plot(GUI.rightImageHandle, rightImageQuads(quadsNum,:,1), rightImageQuads(quadsNum,:,2), 'k.', 'MarkerEdgeColor', color, 'MarkerSize', 10);
            plot(GUI.rightImageHandle, rightImageQuads(quadsNum,:,1), rightImageQuads(quadsNum,:,2), 'k-', 'Color', color); 
        end
    end  % for screen
%        
    UpdateRealWorldCoordsPlot('on');
end


% Method called when the user presses the New (R,L) point button. The method
% presents a cross-hair with which the user has to select a pair of
% points: one for the left image and a corresponding one for the right
% image.
function NewPoint_Callback(varargin)   
    global GUI
    global leftImageSamples
    global rightImageSamples
    global PointsColors

    % bring the leftImage handle in focus
    axes(GUI.leftImageHandle);

    for screen = 1:2
        % Get 1 input point from each screen
        [x,y] = ginput(1);
        
        if (gca == GUI.leftImageHandle)
            % add point to leftImageSamples list
            leftImageSamples = [leftImageSamples; x y];
            
            % get a color according to the points entry in the list
            currentPointIndex = size(leftImageSamples,1);
            color = squeeze(PointsColors(mod(currentPointIndex-1,8)+1, :));
            
            % plot point on top of the left image
            hold(GUI.leftImageHandle, 'on');
            plot(GUI.leftImageHandle, x,y, 'ko', 'MarkerFaceColor', color, 'MarkerSize', 10);
            
            % update coords box
            set(GUI.leftImagePointHandle, 'string', sprintf('(L): %02.1f , %02.1f', x,y));    
        elseif (gca == GUI.rightImageHandle)
            % add point to leftImageSamples list
            rightImageSamples = [rightImageSamples; x y];
            
            % get a color according to the points entry in the list
            currentPointIndex = size(rightImageSamples,1);
            color = squeeze(PointsColors(mod(currentPointIndex-1,8)+1, :));
            
            % plot point on top of the right image
            hold(GUI.rightImageHandle, 'on');
            plot(GUI.rightImageHandle, x,y, 'ko', 'MarkerFaceColor', color, 'MarkerSize', 10);
            
            % update coords box
            set(GUI.rightImagePointHandle, 'string', sprintf('(R): %02.1f , %02.1f', x,y));   
        else
            CodeDevHelper.DisplayModalMessageBox('Point was not added to any list !', 'Error');
        end  
    end  % for screen
    
    UpdateRealWorldCoordsPlot('on');
end


% Method that computes the 3D coords of the virtual point corresponding
% to a selected stereo-pair point and/or quads
function UpdateRealWorldCoordsPlot(mode)
    global GUI
    global xaxis
    global zaxis
    global leftImageSamples
    global rightImageSamples
    global leftImageQuads
    global rightImageQuads
    global quadsNum
    global virtualSceneDistanceFromObserverInCm
    global interPupilarySeparationInCm
    global PointsColors
    global drawRaysOption
    global drawScreenCoordsOption
    
    inputPoints = size(rightImageSamples,1);
    
    axes(GUI.XZplotHandle);
    hold(GUI.XZplotHandle, mode);

    % Plot the vergence plane
    plot([xaxis(1) xaxis(end)], virtualSceneDistanceFromObserverInCm*[1 1], 'k-', 'LineWidth', 5, 'Color', [0.65 0.65 0.65]);
    hold(GUI.XZplotHandle, 'on');
    
    % Plot the left and right eyes
    plot(-interPupilarySeparationInCm/2, 0.0, 'ko', 'MarkerFaceColor', [0 0 0], 'MarkerSize', 16);
    plot(interPupilarySeparationInCm/2, 0.0, 'ko', 'MarkerFaceColor', [0 0 0], 'MarkerSize', 16);
    
    if (size(leftImageSamples,1) ~= size(rightImageSamples,1))
        CodeDevHelper.DisplayModalMessageBox('Numbers of left and right screen points do not match. Please restart!', 'Error');
        return;
    end
   
    % Plot the (x,z) coords of the selected points 
    for k = 1: inputPoints        
        % Select color
        color = squeeze(PointsColors(mod(k-1,8)+1, :));
        
        % Get the L,R pair 
        xLeftScreen   = leftImageSamples(k,1);
        yLeftScreen   = leftImageSamples(k,2);
        xRightScreen  = rightImageSamples(k,1);
        yRightScreen  = rightImageSamples(k,2);
        
        % Call the screenCoordsToVirtualXYZposition method of
        % StereoViewController to compute the XYZ coords from the L,R pair of points
        [Xi, Yi, Zi] = ...
            StereoViewController.screenCoordsToVirtualXYZposition( xLeftScreen, yLeftScreen, ...
            xRightScreen, yRightScreen, virtualSceneDistanceFromObserverInCm, interPupilarySeparationInCm);
        
        fprintf('point %d: %f %f %f\n', k, Xi, Yi, Zi);
        
        % Plot the screen coordinates, if this option is selected
        if (drawScreenCoordsOption)
            % Plot the left and right screen coordinates (points on the vergence lane)
            plot(xLeftScreen, virtualSceneDistanceFromObserverInCm, 'ks', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 10);
            plot(xRightScreen, virtualSceneDistanceFromObserverInCm, 'ks', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 10);
        end
         
         % Plot the vergence rays, if this option is selected
         if (drawRaysOption)
             if (Zi < virtualSceneDistanceFromObserverInCm)
                 % the virtual image is located in front of the vergence plane
                plot([-interPupilarySeparationInCm/2 xLeftScreen], [0 virtualSceneDistanceFromObserverInCm], 'k-', 'Color', color, 'LineWidth', 1.0); 
                plot([interPupilarySeparationInCm/2 xRightScreen], [0 virtualSceneDistanceFromObserverInCm], 'k-', 'Color', color, 'LineWidth', 1.0); 
             else
                 % the virtual image is located behind the vergence plane
                plot([-interPupilarySeparationInCm/2 xLeftScreen], [0 virtualSceneDistanceFromObserverInCm], 'k-', 'Color', color, 'LineWidth', 1.0); 
                plot([interPupilarySeparationInCm/2 xRightScreen], [0 virtualSceneDistanceFromObserverInCm], 'k-', 'Color', color, 'LineWidth', 1.0);  
                plot([-interPupilarySeparationInCm/2 Xi], [0 Zi], 'k--', 'Color', color); 
                plot([interPupilarySeparationInCm/2 Xi], [0 Zi], 'k--', 'Color', color);  
             end
         end
         
         % Plot the virtual point
         plot(Xi, Zi, 'ko', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'w', 'MarkerSize', 12, 'LineWidth', 1.0);
    end

    % Update the [X,Y,Z] text fields
    if (inputPoints > 0)
        set(GUI.virtual3DPointXcoordHandle, 'String', sprintf('virtual X: %02.1f', Xi));
        set(GUI.virtual3DPointYcoordHandle, 'String', sprintf('virtual Y: %02.1f', Yi));
        set(GUI.virtual3DPointZcoordHandle, 'String', sprintf('virtual Z: %02.1f', Zi));
    end
    
    
    % Plot the (x,z) coords of the selected quads
    if ((~isempty(leftImageQuads)) && (~isempty(rightImageQuads))) 
        
        for quad = 1:quadsNum
            for k = 1:5       
                % Get the quad color
                color = squeeze(PointsColors(mod(quad -1,8)+1, :));
                
                % Get the L,R pair
                xLeftScreen   = leftImageQuads(quad,k,1);
                yLeftScreen   = leftImageQuads(quad,k,2);
                xRightScreen  = rightImageQuads(quad,k,1);
                yRightScreen  = rightImageQuads(quad,k,2);
            
                % Call the screenCoordsToVirtualXYZposition method of
                % StereoViewController to compute the XYZ coords from the L,R pair of points
                [Xi(k), Yi(k), Zi(k)] = ...
                    StereoViewController.screenCoordsToVirtualXYZposition( xLeftScreen, yLeftScreen, ...
                    xRightScreen, yRightScreen, virtualSceneDistanceFromObserverInCm, interPupilarySeparationInCm);
        
                % Plot the (X,Z) vertices of the quad
                plot(Xi(k), Zi(k), 'k.', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerSize', 12, 'LineWidth', 1.0);
            end
            
            % plot the XZ outline of the quad
            plot(Xi, Zi, 'k-', 'Color', color, 'LineWidth', 1.0); 
            
        end % quadsNum
    end
    
    hold(GUI.XZplotHandle, 'off');
    set(GUI.XZplotHandle, 'FontName', 'Helvetica', 'FontSize', 16);
    set(GUI.XZplotHandle, 'XLim', [xaxis(1) xaxis(end)], 'YLim', [zaxis(1) zaxis(end)], 'XColor', 'b', 'YColor', 'b');
    set(GUI.XZplotHandle, 'YAxisLocation', 'right');
    box(GUI.XZplotHandle, 'on')
    xlabel(GUI.XZplotHandle, 'Real world X-axis (cm)');
    ylabel(GUI.XZplotHandle, 'Real world Z-axis - depth (cm)');
    set(GUI.XZplotHandle, 'Color', [0.46 0.46 0.46]);
end
