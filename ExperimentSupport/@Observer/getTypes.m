function [exptype, obtype] = getTypes(ob)
% [exptype, obtype] = getTypes(ob)
%
% Returns the experiment type an observer object is set to look at,
% and the type of observation/decision algorithm it is set to use.
% 
%
% 10/29/09 bjh      Created it.

exptype = ob.experimentType;
obtype = ob.observerType;

end