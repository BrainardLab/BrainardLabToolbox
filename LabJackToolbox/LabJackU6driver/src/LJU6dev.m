% Class for handing analog signal acquisition via a LabJack U6 device.
% 
% For example usage, see demoLJU6.m
%
% 6/5/17  npc    Wrote it. The current functionality includes 1kHz/channel sampling
%                from 5 channels, simultaneously.

classdef LJU6dev < handle
    %LJU6dev Class for interfacing with a LABJACK U6 dev
    %   
    
    properties
        verbosity = 0
    end
    
    properties (Access = private)
        isOpen = false;
        sampleDuration = 1.0/1000;
    end
    
    % Public methods
    methods 
        % Constructor
        function obj = LJU6dev(varargin)
            % Parse optional arguments
            parser = inputParser;
            parser.addParameter('verbosity', 0, @isnumeric);
            %Execute the parser
            parser.parse(varargin{:});
            obj.verbosity = parser.Results.verbosity;
        end
        
        function open(obj)
            isU6 = LJU6('identify');
            if (isU6 == 1)
                LJU6('close'); pause(0.5);
                status = LJU6('open');
                if (status ~= 1)
                    error('Could not open U6 device. Unplug, replug U6, and try again.');
                end
            else
                error('No U6 device detected\n');
            end
            obj.isOpen = true;
        end
        
        function close(obj)
            LJU6('close');
            obj.isOpen = false;
        end
        
        function [data, timeAxis] = record(obj, recordingDurationSeconds)
            if (nargin < 2)
                error('Please supply a recording duration\n');
            end
            
            fprintf('Please wait. Acquiring data for %2.1f seconds\n', recordingDurationSeconds);
            [status, data] = LJU6('measure', recordingDurationSeconds);
            timeAxis = (0:1:(size(data,1)-1)) * obj.sampleDuration;
            if (status ~= 1)
                fprintf(2,'Something went wrong during the recording. Unplug, replug U6, and try again\n');
                LJU6('close');
            end
        end
    end % methods
    
end

