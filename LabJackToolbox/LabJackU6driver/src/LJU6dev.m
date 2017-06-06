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
        sampleDuration;
        inputChannels;
    end
    
    properties (Constant)
        validChannelsList = {'AIN0', 'AIN1', 'AIN2', 'AIN3', 'AIN4'};
    end
    
    % Public methods
    methods 
        % Constructor
        function obj = LJU6dev(varargin)
            % Parse optional arguments
            p = inputParser;
            p.addParameter('verbosity', 0, @isnumeric);
            p.addParameter('inputChannels', {'AIN0'}, @iscell);
            p.addParameter('samplingFrequencyKHz', 1.0, @isnumeric);
            %Execute the parser
            p.parse(varargin{:});
            
            % Validate sampling frequency
            if (p.Results.samplingFrequencyKHz ~= 1.0)
                error('Unavailable sampling frequency. Currently only 1.0 kHz is available.');
            end
            
            % Validate input channels
            if any(~ismember(p.Results.inputChannels, obj.validChannelsList))
                fprintf(2,'\nWrong input channel specification. \nSpecify a cell array with any or all of the following:');
                for k = 1:numel(obj.validChannelsList)
                    fprintf(2, ' %s ', obj.validChannelsList{k});
                end
                fprintf(2,'\n');
                error('wrong input channel specification');
            else
                obj.inputChannels = unique(p.Results.inputChannels);
            end
            
            obj.sampleDuration = 1.0/(1000*p.Results.samplingFrequencyKHz);
            obj.verbosity = p.Results.verbosity;
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
                error('No U6 device detected');
            end
            obj.isOpen = true;
        end
        
        function close(obj)
            LJU6('close');
            obj.isOpen = false;
        end
        
        function [data, timeAxis, channelLabels] = record(obj, recordingDurationSeconds)
            if (nargin < 2)
                error('Please supply a recording duration\n');
            end
            
            fprintf('Please wait. Acquiring data for %2.1f seconds\n', recordingDurationSeconds);
            [status, allData] = LJU6('measure', recordingDurationSeconds);
            timeAxis = (0:1:(size(allData,1)-1)) * obj.sampleDuration;
            data = zeros(size(allData,1), numel(obj.inputChannels));
            channelIndex = 0;
            for allChannelIndex = 1:size(allData,2)
                if ismember(obj.validChannelsList{allChannelIndex}, obj.inputChannels)
                    channelIndex = channelIndex + 1;
                    data(:, channelIndex) = allData(:, allChannelIndex);
                    channelLabels{channelIndex} = obj.validChannelsList{allChannelIndex};
                end
            end
            
            if (status ~= 1)
                fprintf(2,'Something went wrong during the recording. Unplug, replug U6, and try again\n');
                LJU6('close');
            end
        end
    end % methods
    
end

