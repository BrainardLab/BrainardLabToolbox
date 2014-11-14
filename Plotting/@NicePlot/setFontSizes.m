function setFontSizes(figHandle, varargin)

    self.fontName = 'Helvetica';
    self.fontSize = 12;
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('fontName', self.fontName);
    parser.addParamValue('fontSize', self.fontSize);
 
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       self.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    axisHandle = findobj(figHandle,'Type','axes');
    set(axisHandle, 'fontName', self.fontName, 'fontSize', self.fontSize);
    
    labelHandles = get(axisHandle,'xlabel');
    for k = 1:numel(labelHandles)
        set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.30), 'fontWeight', 'b');
    end
    
    labelHandles = get(axisHandle,'ylabel');
    for k = 1:numel(labelHandles)
        set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.30), 'fontWeight', 'b');
    end
    
    labelHandles = get(axisHandle,'title');
    for k = 1:numel(labelHandles)
        set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.50), 'fontWeight', 'b');
    end
        
    legendHandles = findobj(figHandle,'Tag','legend');
    for k = 1:numel(legendHandles)
        set(legendHandles(k), 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.0), 'fontWeight', 'b');
    end
end
