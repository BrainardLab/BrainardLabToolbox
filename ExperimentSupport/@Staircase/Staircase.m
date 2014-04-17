function st = Staircase(staircaseType, initialGuess, varargin)
% st = Staircase(staircaseType, initialGuess, property-list...)
%
% Description: Creates a Staircase object.
%
% 10/19/09  dhb  Major rewrite, will break old usage.
% 10/21/09  dhb  Blotto NumIntervals parameter, which isn't used.
% 02/08/11  dhb  Track stepsizes for staircase version.

if (nargin < 2)
    error('Usage: st = Staircase(staircaseType, initialValue, property-list...)');
end

% Create parser object
parser = inputParser;

% Parser values common to all staircase types.
parser.addRequired('StaircaseType', @ischar);
parser.addRequired('InitialGuess', @isscalar);

% Create the input parser object based on the type of staircase specified.
% We use the addOptional method because it allows for flexible input formatting,
% but actual passing of these arguments is enforced by checking below.
staircaseType = lower(staircaseType);
switch staircaseType
    case 'standard'
        % These arguments we require to be passed.
        parser.addOptional('StepSizes',[]);                         % Vector of step sizes to step through
        parser.addOptional('NUp', NaN, @isscalar);                  % Number of correct responses before decrease
        parser.addOptional('NDown',NaN, @isscalar);                 % Number of incorrect responses before increase
	
        
    case 'quest'
        % These arguments we require to be passed.
        parser.addOptional('Beta', NaN, @isscalar);                 % See Quest documentation for these
        parser.addOptional('Delta', NaN, @isscalar);
        parser.addOptional('PriorSD', NaN, @isscalar);
        parser.addOptional('TargetThreshold', NaN, @isscalar);
        parser.addOptional('Gamma', NaN,@isscalar);

    otherwise
        error('Invalid staircase type: %s', staircaseType);
end
parser.addOptional('MaxValue', Inf, @isscalar);                     % Never return recommendation more than this
parser.addOptional('MinValue', -Inf, @isscalar);                    % Never return recommendtation less than this

% Execute the parser to make sure input is good.
parser.parse(staircaseType, initialGuess, varargin{:});

% Create a standard Matlab structure from the parser results.
st = parser.Results;

% Check that required string/value arguments have been set explicitly.
switch staircaseType
    case 'standard'
        if (~isfield(st,'StepSizes') | ~isvector(st.StepSizes) | isempty(st.StepSizes) )
            error('Must pass ''StepSizes'' parameter explicitly in parameter list');
        end
        if (isnan(st.NUp))
            error('Must pass ''NUp'' parameter explicitly in parameter list');
        end
        if (isnan(st.NDown))
            error('Must pass ''NDown'' parameter explicitly in parameter list');
        end
    case 'quest'
        if (isnan(st.Beta))
            error('Must pass ''Beta'' parameter explicitly in parameter list');
        end
        if (isnan(st.Delta))
            error('Must pass ''Delta'' parameter explicitly in parameter list');
        end
        if (isnan(st.Gamma))
            error('Must pass ''Gamma'' parameter explicitly in parameter list');
        end
        if (isnan(st.TargetThreshold))
            error('Must pass ''TargetThreshold'' parameter explicitly in parameter list');
        end
        
    otherwise
        error('Invalid staircase type: %s', staircaseType);
end


% Do any staircase type specific stuff here, such as initialization of data
% structures.
switch staircaseType
    case 'standard'
        st.Stepindex = 1;
        st.NextValue = st.InitialGuess;
        st.Reversals = NaN;
        st.AtSmallestStep = NaN;
        st.SmallestStep = NaN;
        st.UpDownCounter = 0;
        st.CountType = NaN;
        st.NStepSizes = length(st.StepSizes);
        st.LastChange = NaN;
        %st.TrialStepIndices = NaN;
        
    case 'quest'
        st.QuestObj = QuestCreate(log10(st.InitialGuess), log10(st.PriorSD), ...
            st.TargetThreshold, st.Beta, st.Delta, st.Gamma);

end

st.Values = NaN;
st.Responses = NaN;
st.NextTrial = 1;


% Create class
st = class(st, 'Staircase');

