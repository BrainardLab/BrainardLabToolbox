function x = ObserverParamsToVec(type,params)
% Convert structure of observer parameters to vector form
%
% Synopsis:
%   x = ObserverVecToParams(params)
%
% Description:
%   Our goal is to used forced choice color similarity judgments to
%   determine observer parameters.  Sometimes we want those parameters
%   as a vector, and sometimes in a structure.  This routine goes from
%   the structure to the vector.
%
%   This illustrates the transformation, in the reverse direction, for the
%   'basic' type.
%       params.coneParams.indDiffParams.dlens = x(1);
%       params.coneParams.indDiffParams.dmac = x(2);
%       params.coneParams.indDiffParams.dphotopigment(1) = x(3);
%       params.coneParams.indDiffParams.dphotopigment(2) = x(4);
%       params.coneParams.indDiffParams.dphotopigment(3) = x(5);
%       params.coneParams.indDiffParams.lambdaMaxShift(1) = x(6);
%       params.coneParams.indDiffParams.lambdaMaxShift(2) = x(7);
%       params.coneParams.indDiffParams.lambdaMaxShift(3) = x(8);
%       params.colorDiffParams.noiseSd = x(9);
%
% Inputs:
%   type                    - Type of vector to set up.
%                             'basic': Asano cones plus difference noise.
%   params                  - Parameter structure.
%
% Outputs:
%   x                       - Parameters as vector. 
%
% Optional key value pairs:
%   None.
%
% See also:
%   ObserverVecToParams, ComputeCIEConeFundamentals
%

% History:
%   08/09/19  dhb  Wrote it, because I have to do one fun thing this summer.

switch (type)
    case 'basic'
        x = zeros(1,9);
        x(1) = params.coneParams.indDiffParams.dlens;
        x(2) = params.coneParams.indDiffParams.dmac;
        x(3:5) = params.coneParams.indDiffParams.dphotopigment;
        x(6:8) = params.coneParams.indDiffParams.lambdaMaxShift;
        x(9) = params.colorDiffParams.noiseSd;
        
    otherwise
        error('Unknown parameter vector type requested');
        
end
