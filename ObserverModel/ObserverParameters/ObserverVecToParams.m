function params = ObserverVecToParams(type,x,params)
% Convert vector of observer parameters to a structure
%
% Synopsis:
%   params = ObserverVecToParams(type,x,params)
%
% Description:
%   Our goal is to used forced choice color similarity judgments to
%   determine observer parameters.  Sometimes we want those parameters
%   as a vector, and sometimes in a structure.  This routine goes from
%   the vector to the structure.
%
%   This illustrates the transformation. Other fields of passed params
%   structure are left unchanged.
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
%   x                       - Parameters as vector.
%   params                  - Base parameter structure.
%
% Outputs:
%   params                  - Parameter structure.
%
% Optional key value pairs:
%   None.
%
% See also:
%   ObserverParamsToVec, ComputeCIEConeFundamentals
%

% History:
%   08/09/19  dhb  Wrote it, because I have to do one fun thing this summer.

% Examples:
%{
    params.coneParams = DefaultConeParams('cie_asano');
    x = (1:9);
    params = ObserverVecToParams('basic',x,params);
    params.coneParams.indDiffParams
    x1 = ObserverParamsToVec('basic',params)
    if (any(x - x1) ~= 0)
        error('Routines do not properly self invert');
    end
%}

switch (type)
    case 'basic'
        params.coneParams.indDiffParams.dlens = x(1);
        params.coneParams.indDiffParams.dmac = x(2);
        params.coneParams.indDiffParams.dphotopigment = x(3:5)';
        params.coneParams.indDiffParams.lambdaMaxShift = x(6:8)';
        params.colorDiffParams.noiseSd = x(9);
        params.coneParams.indDiffParams.shiftType = 'linear';
        
    otherwise
        error('Unknown parameter vector type requested');
        
end


