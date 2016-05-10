% Helper method for updating the outlet properties
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.
function setOutlets(obj, s)

    % set the values of the outlets
    outletNames = fieldnames(s);
    for k = 1:numel(outletNames)
        obj.(outletNames{k}) = s.(outletNames{k});
    end
end

