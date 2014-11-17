% Class that defines the behavior of a MutationTarget object.
% Mutation target objects contain a number of regions that specify how an
% image is going to be mutated by the PartitiveImageSynthesizer object.
% The sourceChromaROI specifies the region over which we measure the nominal
% chromaticity of the basis images in the source display
% The sourceMask region specifies the region that will be mutated in the
% source display.
% The destMask_XXXDisplay regions specify the destination regions in each
% of the attached displays
%
%
% 6/13/2013  npc Wrote it.
%

classdef MutationTarget
	% public properties
	properties
		% name of mutable target
		name = [];

		% identifier of display on which the @ref sourceChromaROI and @ref cutROI are defined
		sourceDisplayPos;

		% region over which to measure the source mean chromaticity
		sourceChromaROI = [];

		% mask for the source patch
		sourceMask = [];

		% size of mask ramp (in pixels) for blending the cut region onto the paste region
		sourceMaskRampSize = 0;

        % type of mask ramp. Choose between: 'Linear' and 'Gaussian'
		sourceMaskRampType = 'Linear';
        
		% mask for the destination region on frontLeftDisplay
		destMask_FrontLeftDisplay = [];

		% mask for the destination region on frontRightDisplay
		destMask_FrontRightDisplay = [];

		% mask for the destination region on rearLeftDisplay
		destMask_RearLeftDisplay = []

		% mask for the destination region on rearRightDisplay
		destMask_RearRightDisplay = [];

		% flag indicating whether to show the borders of the sourceChromaROI
        % region and of the destMask regions. 
		showBorders = false;
        
        % flag indicating whether to show the insides of the sourceChromaROI
        % region and of the destMask regions. 
		showInsides = false;
        
	end

	properties (SetAccess = private)
		isFeasible = true;
	end

	properties (Constant)
		frontLeftDisplay  = 1;
		frontRightDisplay = 2;
		rearLeftDisplay   = 3;
		rearRightDisplay  = 4;
	end

	methods
		% Constructor
		function self = MutationTarget(varargin)
			parser = inputParser;
			parser.addParamValue('name', self.name);
			parser.addParamValue('sourceDisplayPos', self.sourceDisplayPos);
            parser.addParamValue('sourceChromaROI', self.sourceChromaROI);
            parser.addParamValue('sourceMaskRampSize', self.sourceMaskRampSize);
            parser.addParamValue('sourceMaskRampType', self.sourceMaskRampType);
            parser.addParamValue('sourceMask', self.sourceMask);
            parser.addParamValue('destMask_FrontLeftDisplay', self.destMask_FrontLeftDisplay);
            parser.addParamValue('destMask_FrontRightDisplay', self.destMask_FrontRightDisplay);
            parser.addParamValue('destMask_RearLeftDisplay', self.destMask_RearLeftDisplay );
            parser.addParamValue('destMask_RearRightDisplay', self.destMask_RearRightDisplay);
            parser.addParamValue('showBorders', self.showBorders);
            parser.addParamValue('showInsides', self.showInsides);
            % Execute the parser to make sure input is good
			parser.parse(varargin{:});
            % Copy the parse parameters to the ExperimentController object
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               self.(pNames{k}) = parser.Results.(pNames{k}); 
            end
		end
	end

	% Getter methods
	methods 

		% Gettter for isFeasible
		function value = get.isFeasible(self)
			value = true;
			assert(self.sourceChromaROI.isFeasible, sprintf('sourceChromaROI in mutation target "%s" is not feasible.\n', self.name));
			assert(self.sourceMask.isFeasible, sprintf('sourceMask in mutation target "%s" is not feasible.\n', self.name));
			assert(~((~isempty(self.destMask_FrontLeftDisplay)  && ~self.destMask_FrontLeftDisplay.isFeasible)),  sprintf('destiMask_FrontLeftDisplay is not feasible\n'));
			assert(~((~isempty(self.destMask_FrontRightDisplay) && ~self.destMask_FrontRightDisplay.isFeasible)), sprintf('destiMask_FrontRightDisplay is not feasible\n'));
			assert(~((~isempty(self.destMask_RearLeftDisplay)   && ~self.destMask_RearLeftDisplay.isFeasible)),  sprintf('destiMask_RearLeftDisplay is not feasible\n'));
			assert(~((~isempty(self.destMask_RearRightDisplay)  && ~self.destMask_RearRightDisplay.isFeasible)), sprintf('destiMask_RearRightDisplay is not feasible\n'));
		end
	end
end