% Class that defines a struct with all the options that are settable for
% all Calibrator objects. We use this instead of a basic struct for a
% the following reasons: (i) field name checking (to avoid typos in field names)
% (ii) field value checking (to avoid incorrect field value types).
%
% 3/13/2014  npc Wrote it.
%

classdef CalibratorOptions
	% public properties
	properties 
		% Verbosity level (1 = minimal, 10 = max)
        verbosity = 1;

        % Name of person that is doing the calibration
        whoIsDoingTheCalibration = 'not specified';
        
        % email address to send notification that calibration is done
        emailAddressForDoneNotification = '';
                
        % Flag indicating whether to black the other screen
        blankOtherScreen = 0;
        
        % Screen ID to be blanked
        whichBlankScreen = 1;
        
        % RGB settings for blank screen
        blankSettings = [0 0 0];
        
        % RGB settings for the background color
        bgColor = [0.6603  0.5577  0.4284];
        
        % RGB settings for the primaries that are not been measured
        fgColor = [0.3000  0.6000  0.5000];
        
        % Settings for measurements that allow a background linearity check
        backgroundDependenceSetup = struct( ...
                    'bgSettings',   [], ...
                    'settings',     [] ...
                    );     
                
        % Distance of meter to display in meters
        meterDistance = 0.5;
        
        % Time (in seconds) to leave the room
        leaveRoomTime = 10;
        
        % Sample averages
        nAverage = 1;
        
        % Number of samples in the [0..1] range (RGB settings) 
        nMeas = 25;
        
        % Target size (in pixels)
        boxSize = 150;
        
        % X-offset (in pixels) of square on screen (used to check off-axis monitor properties)
        boxOffsetX = 0;
        
        % X-offset (in pixels) of square on screen (used to check off-axis monitor properties)
        boxOffsetY = 0;
                
        % Flag indicaring whether to skip the linearity test
        skipLinearityTest = false;
        
        % Number of basis vectors in the linear calibration model
        primaryBasesNum = 1;
        
        % The gamma fit configuration
        gamma = struct( ...
                  'fitType',          'crtPolyLinear', ...
                  'contrastThresh',   1.0000e-03, ...
                  'fitBreakThresh',   0.02 ...
                );
            

    end % public properties

    properties (Dependent = true)
        % Settings for measurements that allow a basic linearity check
        % This is dependent because it depends on fgColor
        basicLinearitySetup = struct( ...
                'settings', [] ...
            );
    end % Dependent properties
    
    % Public methods
    methods
        
        % Constructor
        function obj = CalibratorOptions(varargin)
            % Method to instantiate a CalibratorOptions object.
            % Example usage:
            % options = CalibratorOptions( ...
            %           'verbosity',            1, ...
            %           'blankOtherScreen',     0, ...
            %           'whichBlankScreen',     whichBlankScreen, ...
            %           'fgColor',              [0.5 0.0 0.0] ...
            %           );
            
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParameter('verbosity',                       obj.verbosity);
            parser.addParameter('whoIsDoingTheCalibration',        obj.whoIsDoingTheCalibration);
            parser.addParameter('emailAddressForDoneNotification', obj.emailAddressForDoneNotification);
            parser.addParameter('blankOtherScreen',                obj.blankOtherScreen);
            parser.addParameter('whichBlankScreen',                obj.whichBlankScreen);
            parser.addParameter('blankSettings',                   obj.blankSettings);
            parser.addParameter('fgColor',                         obj.fgColor);
            parser.addParameter('bgColor',                         obj.bgColor);
            parser.addParameter('meterDistance',                   obj.meterDistance);
            parser.addParameter('leaveRoomTime',                   obj.leaveRoomTime);
            parser.addParameter('nAverage',                        obj.nAverage);
            parser.addParameter('nMeas',                           obj.nMeas);
            parser.addParameter('boxSize',                         obj.boxSize);
            parser.addParameter('boxOffsetX',                      obj.boxOffsetX);
            parser.addParameter('boxOffsetY',                      obj.boxOffsetY);
            parser.addParameter('primaryBasesNum',                 obj.primaryBasesNum);
            parser.addParameter('gamma',                           obj.gamma);
            parser.addParameter('skipLinearityTest',               obj.skipLinearityTest);
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            parserResults = parser.Results;
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
                obj.(pNames{k}) = parserResults.(pNames{k}); 
            end
            
            obj.backgroundDependenceSetup.bgSettings = [ ...
                                    [1.0 1.0 1.0]; ...
                                    [1.0 0.0 0.0]; ...
                                    [0.0 1.0 0.0]; ...
                                    [0.0 0.0 1.0]; ...
                                    [0.5 0.5 0.5]; ...
                                    [0.5 0.0 0.0]; ...
                                    [0.0 0.5 0.0]; ...
                                    [0.0 0.0 0.5]; ...
                                    [0.0 0.0 0.0]  ... 
                                ]';
            obj.backgroundDependenceSetup.settings = [ ...
                                    [1.0 1.0 1.0]; ...
                                    [0.5 0.5 0.5]; ...
                                    [0.5 0.0 0.0]; ...
                                    [0.0 0.5 0.0]; ...
                                    [0.0 0.0 0.5]; ...
                                    [0.0 0.0 0.0]  ...
                                ]';        
                
        end
        
        % Setter method for property verbosity
        function obj = set.verbosity(obj, newValue)
            if isnumeric(newValue)
                if (newValue < 0)
                    obj.verbosity = 0;
                elseif (newValue > 10)
                    obj.verbosity = 10;
                else
                    obj.verbosity = newValue;
                end
            else
               error('Propery ''verbosity'' must be a numeric value in [0 .. 10]'); 
            end
            fprintf('New verbosity level: %d\n', obj.verbosity);
        end
        
        function obj = set.fgColor(obj, newValue)
            if isnumeric(newValue)
                if isvector(newValue)
                    obj.fgColor = newValue;
                else
                    error('Property bgColor must be a numeric [1 x nPrimaries] array');
                end
            else
               error('Property bgColor must be numeric'); 
            end
        end
        
        
        function obj = set.bgColor(obj, newValue)
            if isnumeric(newValue)
                if isvector(newValue)
                    obj.bgColor = newValue;
                else
                    error('Property bgColor must be a numeric [1 x nPrimaries] array');
                end
            else
               error('Property bgColor must be numeric'); 
            end
        end
        
        
        % Getter for dependent property basicLinearitySetup
        function basicLinearitySetup = get.basicLinearitySetup(obj)
            basicLinearitySetup.settings = [ ...
                                [1.00 1.00 1.00] ; ...
                                [1.00 0.00 0.00] ; ...
                                [0.00 1.00 0.00] ; ...
                                [0.00 0.00 1.00] ; ...
                                [0.75 0.75 0.75] ; ...
                                [0.75 0.00 0.00] ; ...
                                [0.00 0.75 0.00] ; ...
                                [0.00 0.00 0.75] ; ...
                                [0.50 0.50 0.50] ; ...
                                [0.50 0.00 0.00] ; ...
                                [0.00 0.50 0.00] ; ...
                                [0.00 0.00 0.50] ; ...
                                [0.25 0.25 0.25] ; ...
                                [0.25 0.00 0.00] ; ...
                                [0.00 0.25 0.00] ; ...
                                [0.00 0.00 0.25] ; ...
                                [0.75 obj.fgColor(2) obj.fgColor(3)] ; ...
                                [0.50 obj.fgColor(2) obj.fgColor(3)] ; ...
                                [0.25 obj.fgColor(2) obj.fgColor(3)] ; ...
                                [0.00 obj.fgColor(2) obj.fgColor(3)] ; ...
                                [obj.fgColor(1) 0.75 obj.fgColor(3)] ; ...
                                [obj.fgColor(1) 0.50 obj.fgColor(3)] ; ...
                                [obj.fgColor(1) 0.25 obj.fgColor(3)] ; ...
                                [obj.fgColor(1) 0.00 obj.fgColor(3)] ; ...
                                [obj.fgColor(1) obj.fgColor(2) 0.75] ; ...
                                [obj.fgColor(1) obj.fgColor(2) 0.50] ; ...
                                [obj.fgColor(1) obj.fgColor(2) 0.25] ; ...
                                [obj.fgColor(1) obj.fgColor(2) 0.00] ; ...
                                [0.0000    0.0000    0.0000] ; ...
                                [0.5378    0.5321    0.5406]; ...
                                [0.4674    0.4249    0.3573]; ...
                                [0.4106    0.4399    0.5388]; ...
                            ]';
                        
        end
        
    end  % public methods
    
    methods (Access = private)        
        % Method to configure the basic linearity setup
        function obj = configureBasicLinearitySetup(obj)
            
        end

    end  % private methods

end % classef