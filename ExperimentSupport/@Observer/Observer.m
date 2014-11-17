function ob = Observer(experimentType, observerType, varargin)
% ob = Observer(experimentType, observerType, propertyList...)
%
% Description: Creates an Observer object. This Observer can be set to look
% at a specific type of experiment and use a specific decision paradigm.
% There is currently no 'setTypes' method- each Observer is born being good
% at one experiment and deciding things about that experiment in one way.
%
% 10/29/09 bjh      Created it.

if (nargin < 2)
    error('Usage: ob = Observer(experimentType, observerType, property-list...)');
end

% Create parser object
parser = inputParser;

% Parser values common to all experiment types.
parser.addRequired('experimentType', @ischar);
parser.addRequired('observerType', @ischar);
parser.addParamValue('discrim', [], @isscalar);
parser.addParamValue('noise', [], @isscalar);

% Execute the parser to make sure input is good.
parser.parse(experimentType, observerType, varargin{:});

% Create a standard Matlab structure from the parser results.
ob = parser.Results;

% Create class
ob = class(ob, 'Observer');

end