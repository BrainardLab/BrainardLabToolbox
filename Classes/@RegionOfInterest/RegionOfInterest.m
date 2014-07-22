% Class that defines a rectangular or elliptical region.
%
% 6/13/2013  npc Wrote it.
%

classdef RegionOfInterest
	% public properties
	properties
		% name of RegionOfInterest
		name = [];

		% x-center of RegionOfInterest, in pixels
		xo = 0;

		% y-center of RegionOfInterest, in pixels
		yo = 0;

		% width of RegionOfInterest, in pixels
		width = 0;

		% height of RegionOfInterest, in pixels
		height = 0;
		
		% rotation angle of RegionOfInterest, in degrees
		rotation = 0;

		% shape of region of interest, currently two values: 
		% RegionOfInterest.Elliptical or RegionOfInterest.Rectangular
		shape = 'Rectangular';
		
		% image width, in pixels
		imageWidth = 1;

		% image height, in pixels
		imageHeight = 1;
	end

	properties (SetAccess = private)
		% Flag indicating whether the RegionOfInterest lies within the image border
		isFeasible = false;
		% Indices of pixels lying within the RegionOfInterest
		insideIndices = [];
		% Indices of pixels lying on the border of the RegionOfInterest
		borderIndices = [];
    end

    properties (Constant)
        Elliptical  = 'Elliptical';
        Rectangular = 'Rectangular';
    end
    
	methods
		% Constructor
		function self = RegionOfInterest(varargin)
			parser = inputParser;
			parser.addParamValue('name', self.name);
			parser.addParamValue('shape', self.shape);
            parser.addParamValue('xo', self.xo);
            parser.addParamValue('yo', self.yo);
            parser.addParamValue('width', self.width);
            parser.addParamValue('height', self.height);
            parser.addParamValue('rotation', self.rotation);
            parser.addParamValue('imageWidth', self.imageWidth);
            parser.addParamValue('imageHeight', self.imageHeight);
            % Execute the parser to make sure input is good
			parser.parse(varargin{:});
            % Copy the parse parameters to the ExperimentController object
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               self.(pNames{k}) = parser.Results.(pNames{k}); 
            end
		end
	end

	methods 
		% Getter for insideIndices
		function value = get.insideIndices(self)
			if (self.isFeasible)
				if strcmpi(self.shape, self.Rectangular)
					[value, ~] = IndicesForRect(self.imageWidth, self.imageHeight, self.xo, self.yo, self.width, self.height, self.rotation);
				elseif (strcmpi(self.shape, self.Elliptical))
					[value, ~] = IndicesForEllipse(self.imageWidth, self.imageHeight, self.xo, self.yo, self.width, self.height, self.rotation); 
				end
			else
				fprintf('Region is not feasible\n');
				beep
				value = [];	
			end
		end

		function value = get.borderIndices(self)
			if (self.isFeasible)
				if strcmpi(self.shape, self.Rectangular)
					[~, value] = IndicesForRect(self.imageWidth, self.imageHeight, self.xo, self.yo, self.width, self.height, self.rotation);
				elseif (strcmpi(self.shape, self.Elliptical))
					[~,value] = IndicesForEllipse(self.imageWidth, self.imageHeight, self.xo, self.yo, self.width, self.height, self.rotation); 
				end
			else
				fprintf('Region is not feasbible\n');
				beep
				value = [];	
			end
        end

        function rampMask = returnRampMask(self, rampSize, rampType)
            rampMask = ComputeRampMask(rampSize, rampType, self.insideIndices, self.imageWidth, self.imageHeight, self.xo, self.yo, self.width, self.height, self.rotation);
        end
        
		% Gettter for isFeasible
		function value = get.isFeasible(self)
			value = true;
			if (self.xo - self.width/2 < 0)
				value = false;
				fprintf('%s is NOT feasible. Check Xcoord/width.\n', self.name);
			elseif (self.yo - self.height/2 < 0)
				value  = false;
				fprintf('%s is NOT feasible. Check Ycoord/height.\n', self.name);
			elseif (self.xo + self.width/2 > self.imageWidth)
				value = false;
				fprintf('%s is NOT feasible. Check Xcoord/width.\n', self.name);
			elseif (self.yo + self.height/2 > self.imageHeight)
				value  = false;
				fprintf('%s is NOT feasible. Check Ycoord/height.\n', self.name);
            end
        end
    end  % methods
end % classdef


function [insideIndices, borderIndices] = IndicesForEllipse(cols, rows, xo, yo, width, height, rotationAngle)
 	[X,Y] = meshgrid(1:cols, 1:rows);
    major = width/2;
    minor = height/2;
 	theta = rotationAngle/180*pi;
    XX = X - xo;
    YY = Y - yo;
 	Xp = XX*cos(theta) +YY*sin(theta);
 	Yp =-XX*sin(theta) +YY*cos(theta);
    X = Xp/major;
    Y = Yp/minor;
    r = X.^2 + Y.^2;
    insideIndices = find(r < 1);
    borderIndices = find(abs(r-1)< 0.1);
end

function rampMask = ComputeRampMask(rampSize, rampType, insideIndices, cols, rows, xo, yo, width, height, rotationAngle)
    [X,Y] = meshgrid(1:cols, 1:rows);
    theta = rotationAngle/180*pi;
    XX = X - xo;
    YY = Y - yo;
 	Xp = round(XX*cos(theta) +YY*sin(theta));
 	Yp = round(-XX*sin(theta) +YY*cos(theta));
    
    w2 = width/2;
    h2 = height/2;
    rampMask = zeros(rows,cols);
    rampMask(insideIndices) = 1;
    
    % sigma (only relevant if rampType == 'Gaussian')
    sigma = 0.34;
    
    if (rampSize > 0)
        % left side
        marginIndices = find((Xp <= -(w2-rampSize)) & (Xp >= -w2) & (Yp >= -h2) & (Yp <= h2));
        ramp = (Xp(marginIndices)+w2)/rampSize;
        if strcmpi(rampType,'Linear')
            rampMask(marginIndices) = ramp;
        else
            rampMask(marginIndices) = 1-exp(-0.5*(ramp/sigma).^2);
        end
        
        % right side
        marginIndices = find((Xp >= (w2-rampSize)) & (Xp <= w2) & (Yp >= -h2) & (Yp <= h2));
        ramp = (w2-Xp(marginIndices))/rampSize;
        if strcmpi(rampType,'Linear')
            rampMask(marginIndices) = ramp;
        else
            rampMask(marginIndices) = 1-exp(-0.5*(ramp/sigma).^2);
        end
    
        % bottom side
        marginIndices = find((Xp >= -w2) & (Xp <= w2) & (Yp < -(h2-rampSize)) & (Yp >= -h2));
        ramp = (Yp(marginIndices)+h2)/rampSize;
        if strcmpi(rampType,'Linear')
            rampMask(marginIndices) = rampMask(marginIndices) .* ramp;
        else
            rampMask(marginIndices) = rampMask(marginIndices) .* (1-exp(-0.5*(ramp/sigma).^2));
        end
        
        % top side
        marginIndices = find((Xp >= -w2) & (Xp <= w2) & (Yp > (h2-rampSize)) & (Yp <= h2));
        ramp = (h2-Yp(marginIndices))/rampSize;
        if strcmpi(rampType,'Linear')
            rampMask(marginIndices) = rampMask(marginIndices) .* ramp;
        else
            rampMask(marginIndices) = rampMask(marginIndices) .* (1-exp(-0.5*(ramp/sigma).^2));
        end
    
        %figure(1);
        %imagesc(rampMask)
        %set(gca, 'CLim', [0 1]);
        %colormap(gray);
        %pause
    end
    
end

function [insideIndices, borderIndices] = IndicesForRect(cols, rows, xo, yo, width, height, rotationAngle)
	[X,Y] = meshgrid(1:cols, 1:rows);
    theta = rotationAngle/180*pi;
    XX = X - xo;
    YY = Y - yo;
 	Xp = round(XX*cos(theta) +YY*sin(theta));
 	Yp = round(-XX*sin(theta) +YY*cos(theta));
                      
    zero = 10*eps;
    XXp = abs(Xp) - width/2;
    YYp = abs(Yp) - height/2;
    
	insideIndices = find((XXp <= zero) & (YYp <= zero));
    borderIndices = find( ((XXp <= zero) & (XXp > -2) & (Yp > -height/2) & (Yp < height/2)) | ((YYp <= zero) & (YYp > -2) & (Xp > -width/2) & (Xp < width/2))) ;
    
end

