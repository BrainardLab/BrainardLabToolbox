% The PartitiveImageSynthesizer class mutates the chromaticity of an image 
% region using partitive image mixing of a set of basis images. The class
% allows the user to specify an arbitrary number of mutation targets,
% each with a different target chromaticity and generates mutated images for 
% up to four displays (e.g. for the Stereo HDR rig)
%
% The basic usage of this class is demonstrated by the following code:
%
% (1) Initialization of an PartitiveImageSynthesizer object by passing the
%     directory of the bas2is images and their filesnames for each display position
%
%	imageSynthesizer = PartitiveImageSynthesizer( 'imageDir',    imageDirectory , ...
%					'basisImageFileNamesFrontLeftDisplay',  basisImageFileNamesForFrontLeftDisplay, ...
%					'basisImageFileNamesFrontRightDisplay', basisImageFileNamesForFrontRightDisplay );
%
% (2) Generate mutation targets for the upper button. Make sure that each mutation 
%    target has a unique name. Here we are generating two mutation targets.
%
%   showBordersFlag = true;
%   showInsidesFlag = false;
%   mutationTarget1 = generateMutationTarget1(imageSynthesizer.imageWidth, ...
%                                             imageSynthesizer.imageHeight, ...
%                                             'Upper Button Target', showBordersFlag, showInsidesFlag);
%
%   mutationTarget2 = generateMutationTarget2(imageSynthesizer.imageWidth, ...
%                                             imageSynthesizer.imageHeight, ...
%                                             'Lower Button Target', showBordersFlag, showInsidesFlag); 
%	
% (3) Pass a cell array with all desired mutation targets to the
%     imageSynthesizer, as follows:
%
%	imageSynthesizer.mutationTargets = {mutationTarget1, mutationTarget2};
%
% (4) Generate a container with a tri-stimulus coordinates vector (here LMS) 
%     which contains one chroma entry for each mutation target as follows:
% 
%    sensorActivationMap = containers.Map();
%    sensorActivationMap(mutationTarget1.name) = LinearRGBtoLMS([1 0 0]);
%    sensorActivationMap(mutationTarget2.name) = LinearRGBtoLMS([0 1 0]);
%
% (5) Pass the tristimulus container to the PartitiveImageSynthesizer object
%     The returned argument is a cell array containing the synthesized images, 
%     with each cell containing the image for each of the attached displays
%    (up to four displays, e.g. for the Stereo HDR)
%
%    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
%
% In the case of the Stereo rig, the left and right display images can be
% obtained as follows:
%    leftImage  = mutatedImages{MutationTarget.frontLeftDisplay}.imageData;
%	rightImage  = mutatedImages{MutationTarget.frontRightDisplay}.imageData;
%
% The returned images are in the same chromatic space as the basis images.
%
% 6/13/2013  npc Wrote it.
%

classdef PartitiveImageSynthesizer

	properties
		% cell array {mutationTargetIndex} of MutationTarget objects 
		mutationTargets = {};
	end

	properties (SetAccess = private)
		% basis image width
		imageWidth;

		% basis image height
		imageHeight;

		% number of displays for which we are generating images
		displaysNum = 0;

		% number of basis images
		basisImagesNum = nan;

		% cell array {displayIndex}{basisImageIndex} of basis images
		basisImages = {};

		% cell array {displayIndex} of blanks images, one for each display
		blankImages = {};

		% cell array {displayIndex} of synthesized images, one for each display
		mutatedImages = {};

		% number of mutation targers
		mutationTargetsNum;

		% the nominal sensor activations for all targets and basis images
		% cell array {mutationTargetIndex} of [ basisImagesNum x 3] matrices
		nominalSensorActivations = {};

		% flag indicated whether the synthesizer is initialized
		isInitialized = false;

	end

	% Private properties
	properties (Access = private)
		% Directory where basis images live
		imageDir = '';

		% Names of basis images for the front left display
		basisImageFileNamesFrontLeftDisplay = {};

		% Names of basis images for the front right display
		basisImageFileNamesFrontRightDisplay = {};

		% Names of basis images for the front left display
		basisImageFileNamesRearLeftDisplay = {};

		% Names of basis images for the front left display
		basisImageFileNamesRearRightDisplay = {};
	
		% cell array {displayIndex}{mutationTargetIndex} of pixel indices lying inside the mutation region
		destinationMaskPixelIndices = {};

        % cell array {displayIndex}{mutationTargetIndex} of ramp masks
        rampMask = {};
        
		% cell array {displayIndex}{mutationTargetIndex} of pixel indices lying on the border of the mutation region
		destinationMaskBorderPixelIndices = {};

		% cell array {mutationTargetIndex} of pixels indices lying on the border of the chromaROI 
		sourceChromaBorderPixelIndices = {};

        % cell array {mutationTargetIndex} of pixels indices lying inside the chromaROI 
        sourceChromaPixelIndices = {};
        
		% which display to measure the nominalSensorCoords from
		referenceDisplayPos;
	end


	% public methods
	methods
		% Constructor
		function self = PartitiveImageSynthesizer(varargin)
            % parse inputs
			parser = inputParser;
            parser.addParamValue('imageDir', self.imageDir);
            parser.addParamValue('basisImageFileNamesFrontLeftDisplay',  self.basisImageFileNamesFrontLeftDisplay);
            parser.addParamValue('basisImageFileNamesFrontRightDisplay', self.basisImageFileNamesFrontRightDisplay);
            parser.addParamValue('basisImageFileNamesRearLeftDisplay',   self.basisImageFileNamesRearLeftDisplay);
            parser.addParamValue('basisImageFileNamesRearRightDisplay',  self.basisImageFileNamesRearRightDisplay);

            % Execute the parser to make sure input is good
			parser.parse(varargin{:});
            % Copy the parse parameters to the ExperimentController object
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               self.(pNames{k}) = parser.Results.(pNames{k}); 
            end

            self = self.loadAllBasisImages();
            self.isInitialized = true;
        end

        function value = setMutationTargetSensorActivations(self, sensorActivationMap)
        	% Go through each mutation target and compute the lambda vector for it
        	for mutationTargetIndex = 1:self.mutationTargetsNum
                mutationTarget   = self.mutationTargets{mutationTargetIndex};
                sensorActivation = sensorActivationMap(mutationTarget.name);
                TwConstraint     = [reshape(sensorActivation, [3,1]) ; 1];
        		MwConstraint     = self.nominalSensorActivations{mutationTargetIndex}.data;
				weights{mutationTargetIndex}.lambda = pinv(MwConstraint)*TwConstraint;
            end

        	% Now generate mutated image using these weights and return them
        	value  = self.generateMutatedImagesUsingWeights(weights);
        end
    end  % public methods


    % Getter methods
    methods
        function value = get.mutationTargetsNum(self)
            value = numel(self.mutationTargets);
        end
    
        function value = get.referenceDisplayPos(self)
            value = self.mutationTargets{1}.sourceDisplayPos;
        end
    end
    
    % Setter methods
    methods
    	function self = set.mutationTargets(self, mutationTargets)

            names = {};
            sourceMaskRampSizes = {};
            sourceMaskRampTypes = {};
            for index = 1:numel(mutationTargets)
                assert(mutationTargets{index}.isFeasible, sprintf('Mutation target %s is not valid.', mutationTargets{index}.name));
                names{index} = mutationTargets{index}.name;
                sourceMaskRampSizes{index} = mutationTargets{index}.sourceMaskRampSize;
                sourceMaskRampTypes{index} = mutationTargets{index}.sourceMaskRampType;
            end
            
            % Check to make sure that all mutation targets have unique names
            sameNamesFound = false;
            for ii = 1:numel(names)
                for jj = ii+1:numel(names)
                    if strcmpi(names{ii}, names{jj})
                        sameNamesFound = true;
                    end
                end
            end
            assert(~sameNamesFound, 'Some mutation target have identical names. This is not allowed');
                
            % If we get here all tests have passed. We are good to go.
			fprintf('>>>> Will mutate %d target(s)\n', numel(mutationTargets));
			self.mutationTargets = mutationTargets;
        
			% Compute nominal coords for all targets
			self = self.computeNominalSensorActivations();
            
            % Compute blank images
			if (~isempty(self.basisImageFileNamesFrontLeftDisplay))
				self = self.generateBlankImageForTargetDisplay(MutationTarget.frontLeftDisplay, sourceMaskRampSizes, sourceMaskRampTypes);
			end
			if (~isempty(self.basisImageFileNamesFrontRightDisplay))
				self = self.generateBlankImageForTargetDisplay(MutationTarget.frontRightDisplay, sourceMaskRampSizes, sourceMaskRampTypes);
			end
			if (~isempty(self.basisImageFileNamesRearLeftDisplay))
				self = self.generateBlankImageForTargetDisplay(MutationTarget.rearLeftDisplay, sourceMaskRampSizes, sourceMaskRampTypes);
			end
			if (~isempty(self.basisImageFileNamesRearRightDisplay))
				self = self.generateBlankImageForTargetDisplay(MutationTarget.rearRightDisplay, sourceMaskRampSizes, sourceMaskRampTypes);
            end
            
        end
	end  % setter methods


    % private methods
    methods (Access = private)

    	function mutatedImages = generateMutatedImagesUsingWeights(self, weights)
        	% print weights for each mutation target
            if (false)
                for mutationTargetIndex = 1:self.mutationTargetsNum
                    fprintf('\nWeights for mutation target #%d: ', mutationTargetIndex);
                    for k = 1:length(weights{mutationTargetIndex}.lambda)
                        fprintf('%+2.2f, ', weights{mutationTargetIndex}.lambda(k));
                    end
                    fprintf(' (sum = %2.2f)\n', sum(weights{mutationTargetIndex}.lambda));
                end
            end

            for displayPosID = 1:self.displaysNum
                blankImage  = self.blankImages{displayPosID}.imageDataCalFormat;
                
                for channelIndex = 1:3
                    channelImageData = blankImage(channelIndex,:);
                    
                    for mutationTargetIndex = 1:self.mutationTargetsNum
                        insideIndices  = self.destinationMaskPixelIndices{displayPosID, mutationTargetIndex};
                        if (channelIndex == 1)
                            targetRampMask = self.rampMask{displayPosID, mutationTargetIndex};
                            rampMask{mutationTargetIndex} = (targetRampMask(insideIndices))';
                        end
                        
                        for basisImageIndex = 1:self.basisImagesNum
                            channelImageData(insideIndices) = channelImageData(insideIndices) + ...
                                weights{mutationTargetIndex}.lambda(basisImageIndex) .* self.basisImages{displayPosID, basisImageIndex}.imageDataCalFormat(channelIndex,insideIndices) .* rampMask{mutationTargetIndex};
                        end  % basisImageIndex

                        if (self.mutationTargets{mutationTargetIndex}.showBorders)
                            channelImageData(self.destinationMaskBorderPixelIndices{displayPosID, mutationTargetIndex}) = 0.0;
                            if (displayPosID == self.referenceDisplayPos)
                                channelImageData(self.sourceChromaBorderPixelIndices{mutationTargetIndex}) = 1.0;
                            end
                        end
                        if (self.mutationTargets{mutationTargetIndex}.showInsides)
                            channelImageData(self.destinationMaskPixelIndices{displayPosID, mutationTargetIndex}) = 0.0;
                            if (displayPosID == self.referenceDisplayPos)
                                channelImageData(self.sourceChromaPixelIndices{mutationTargetIndex}) = 1.0;
                            end
                        end
                    end  % mutationTargetIndex
                    
                    blankImage(channelIndex,:) = channelImageData;
                end % channelIndex

                mutatedImages{displayPosID}.imageData = CalFormatToImage(blankImage, self.imageWidth, self.imageHeight);
            end % displayPos
            
		end


    	% Method to compute the nominal coords for all mutation targets
    	function self = computeNominalSensorActivations(self)
    		for targetIndex = 1:self.mutationTargetsNum
    			mutationTarget = self.mutationTargets{targetIndex};
    			self.sourceChromaPixelIndices{targetIndex} = mutationTarget.sourceChromaROI.insideIndices;
    			self.sourceChromaBorderPixelIndices{targetIndex} = mutationTarget.sourceChromaROI.borderIndices;
    			data = zeros(self.basisImagesNum, 3+1);
                indices = self.sourceChromaPixelIndices{targetIndex};
    			for basisImageIndex = 1:self.basisImagesNum
                    tmp  = self.basisImages{self.referenceDisplayPos,basisImageIndex}.imageDataCalFormat;
    				alphaChannel = tmp(1,indices);
					betaChannel  = tmp(2,indices);
					gammaChannel = tmp(3,indices);
    				data(basisImageIndex,:) = ...
    					[ mean(alphaChannel), ...
						  mean(betaChannel), ...
						  mean(gammaChannel), ...
						  1 ]; % last entry of all 1's guarantees sum(weights) = 1
    			end
    			self.nominalSensorActivations{targetIndex}.data = data';
    		end
    	end

    	% Method to load all the basis images
    	function self = loadAllBasisImages(self)
			% reset number of displays
			self.displaysNum = 0;
			if (~isempty(self.basisImageFileNamesFrontLeftDisplay))
				self = self.loadBasisImagesForTargetDisplay(self.basisImageFileNamesFrontLeftDisplay, MutationTarget.frontLeftDisplay);
				self.displaysNum = self.displaysNum + 1;
			end
			if (~isempty(self.basisImageFileNamesFrontRightDisplay))
				self = self.loadBasisImagesForTargetDisplay(self.basisImageFileNamesFrontRightDisplay, MutationTarget.frontRightDisplay);
				self.displaysNum = self.displaysNum + 1;
			end
			if (~isempty(self.basisImageFileNamesRearLeftDisplay))
				self = self.loadBasisImagesForTargetDisplay(self.basisImageFileNamesRearLeftDisplay, MutationTarget.rearLeftDisplay);
				self.displaysNum = self.displaysNum + 1;
			end
			if (~isempty(self.basisImageFileNamesRearRightDisplay))
				self = self.loadBasisImagesForTargetDisplay(self.basisImageFileNamesRearRightDisplay, MutationTarget.rearRightDisplay);
				self.displaysNum = self.displaysNum + 1;
			end
		end

		% Method to load basis image for a specific display
		function self = loadBasisImagesForTargetDisplay(self, basisImageFileNames, displayPosID)
			if (isnan(self.basisImagesNum))
				self.basisImagesNum = length(basisImageFileNames);
			elseif (self.basisImagesNum ~= length(basisImageFileNames))
				string = sprintf('Fatal error: different number of basis images for different displays');
                disp(string);
                Speak(string, 'Alex');
                return;
            end
            
            tic
            
            for basisImageIndex = 1:self.basisImagesNum
                filename = fullfile(self.imageDir, basisImageFileNames{basisImageIndex});
                if (~isempty(findstr(filename, 'png'))) || (~isempty(findstr(filename, 'jpg')))
                    % import sRGB image
                    im = double(imread(filename));
                    fprintf('Range of input image %d: [%2.4f - %2.4f]\n', basisImageIndex, min(min(min(im))), max(max(max(im))));
                    % to calFormat for efficient computations
                    [im, imageCols, imageRows] = ImageToCalFormat(im);
                    % undo standard sRGB gamma correction, to go into linear coordinates
                    im   = SRGBGammaUncorrect(im);
					% also get image format 
					self.basisImages{displayPosID, basisImageIndex}.imageData = CalFormatToImage(im, imageCols, imageRows);
                    [self.imageHeight, self.imageWidth, ~] = size(self.basisImages{displayPosID, basisImageIndex}.imageData);
                else
                    fprintf('Loading cone image for display %d (%s)\n', displayPosID, filename);
                    % import sensor image
                    sensorImageVariable = whos('-file', filename);
                    load(filename);
                    eval(sprintf('self.basisImages{displayPosID, basisImageIndex}.imageData = %s;',sensorImageVariable.name));
                    eval(sprintf('self.basisImages{displayPosID, basisImageIndex}.imageDataCalFormat = ImageToCalFormat(%s);',sensorImageVariable.name));
                    [self.imageHeight, self.imageWidth, ~] = size(self.basisImages{displayPosID, basisImageIndex}.imageData);
                end
            end
            
            fprintf('Image loading took %2.2f seconds\n', toc);
        end


		% Method to generate a blank image for each display. This is called whenever the mutation targets are set.
		function self = generateBlankImageForTargetDisplay(self, displayPosID, sourceMaskRampSizes, sourceMaskRampTypes)
			% toggle averageBackground for testing
			averageBackground = true;
            if (averageBackground)
				% compute the mean basis image across all basis images for this displayPos
                for basisImageIndex = 1:self.basisImagesNum
                    if (basisImageIndex == 1)
                        imageData = self.basisImages{displayPosID,basisImageIndex}.imageDataCalFormat;
                    else
                        imageData = imageData + self.basisImages{displayPosID,basisImageIndex}.imageDataCalFormat;
                    end				
                end
                backgroundImageData = imageData / self.basisImagesNum;
            else
                backgroundImageData = self.basisImages{displayPosID,1}.imageDataCalFormat;
            end

            for mutationTargetIndex = 1:self.mutationTargetsNum
                self.rampMask{displayPosID, mutationTargetIndex} = self.generateRampMask(sourceMaskRampSizes{mutationTargetIndex}, sourceMaskRampTypes{mutationTargetIndex}, displayPosID, mutationTargetIndex);
                self.destinationMaskPixelIndices{displayPosID, mutationTargetIndex} = self.computeInsideIndicesForTargetDisplay(displayPosID, mutationTargetIndex);
                self.destinationMaskBorderPixelIndices{displayPosID, mutationTargetIndex} = self.computeBorderIndicesForTargetDisplay(displayPosID, mutationTargetIndex);
            end

			% next, go through all mutation targets and zero out the position corresponding to the their mask areas
            for mutationTargetIndex = 1:self.mutationTargetsNum
                indices        = self.destinationMaskPixelIndices{displayPosID, mutationTargetIndex};
                targetRampMask = self.rampMask{displayPosID, mutationTargetIndex};
                bkgndRampMask  = 1-targetRampMask;        
                bkgndRampMask  = (bkgndRampMask(indices))';

                for channelIndex = 1:3
                    channelData = backgroundImageData(channelIndex,:);
                    channelData(indices) = channelData(indices) .* bkgndRampMask;
                    backgroundImageData(channelIndex,:) = channelData;
                end	
            end
            
			self.blankImages{displayPosID}.imageDataCalFormat = backgroundImageData;      
 
        end

        
        
        function rampMask = generateRampMask(self, rampSize, rampType, displayPosID, targetIndex)
            if (displayPosID == MutationTarget.frontLeftDisplay)
				rampMask = self.mutationTargets{targetIndex}.destMask_FrontLeftDisplay.returnRampMask(rampSize, rampType);
			elseif (displayPosID == MutationTarget.frontRightDisplay)
				rampMask = self.mutationTargets{targetIndex}.destMask_FrontRightDisplay.returnRampMask(rampSize, rampType);
			elseif (displayPosID == MutationTarget.rearLeftDisplay)
				rampMask = self.mutationTargets{targetIndex}.destMask_RearLeftDisplay.returnRampMask(rampSize, rampType);
			elseif (displayPosID == MutationTarget.rearRightDisplay)
				rampMask = self.mutationTargets{targetIndex}.destMask_RearRightDisplay.returnRampMask(rampSize, rampType);
            end
        end
        
		% Method to get the indices of pixels lying inside a the destination mask of a given mutation target and a given displayPosID 
		function insideIndices = computeInsideIndicesForTargetDisplay(self, displayPosID, targetIndex)
			if (displayPosID == MutationTarget.frontLeftDisplay)
				insideIndices = self.mutationTargets{targetIndex}.destMask_FrontLeftDisplay.insideIndices;
			elseif (displayPosID == MutationTarget.frontRightDisplay)
				insideIndices = self.mutationTargets{targetIndex}.destMask_FrontRightDisplay.insideIndices;
			elseif (displayPosID == MutationTarget.rearLeftDisplay)
				insideIndices = self.mutationTargets{targetIndex}.destMask_RearLeftDisplay.insideIndices;
			elseif (displayPosID == MutationTarget.rearRightDisplay)
				insideIndices = self.mutationTargets{targetIndex}.destMask_RearRightDisplay.insideIndices;
			end
		end

		% Method to get the indices of pixels lying at the border of the destination mask of a given mutation target and a given displayPosID 
		function borderIndices = computeBorderIndicesForTargetDisplay(self, displayPosID, targetIndex)
			if (displayPosID == MutationTarget.frontLeftDisplay)
                borderIndices = self.mutationTargets{targetIndex}.destMask_FrontLeftDisplay.borderIndices;
			elseif (displayPosID == MutationTarget.frontRightDisplay)
				borderIndices = self.mutationTargets{targetIndex}.destMask_FrontRightDisplay.borderIndices;
			elseif (displayPosID == MutationTarget.rearLeftDisplay)
				borderIndices = self.mutationTargets{targetIndex}.destMask_RearLeftDisplay.borderIndices;
			elseif (displayPosID == MutationTarget.rearRightDisplay)
				borderIndices = self.mutationTargets{targetIndex}.destMask_RearRightDisplay.borderIndices;
			end
        end
	end  % private methods

end % classdef