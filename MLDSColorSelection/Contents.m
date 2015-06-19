% MLDSColorSelection
%
% Routines developed to find inferred match in a color selection paradigm. 
% Adapted from MLDS described by Maloney and Young (2004), but applied for stimulus 
% triads instead of pairs. 
%
% ROUTINES
%
% MLDSColorSelection.m          Main fitting routine. 
% MLDSComputeLogLikelihood.m	Computes log likelihood for a current fit. 
% MLDSIdentityMap.m             Identity mapping. Assumes no context effect. 
% MLDSComputeProb.m             Based on current fits, it computes probability that one element of
%                               the pair is going to be chosen as closer to the target based on current
%                               Can be used for debugging purposes when certain data pattern fit fails. 
% MLDSSimulateResponse.m        Simulates a trial given a target and a competitor pair.
% MLDSColorSelectionPlot.m      Plots the results of MLDS fit: the inferred
%                               positions of the targets and the competiors
%                               and the theoretical vs. predicted responses.
%
% TEST/DEMO
% MLDSColorSelectionDemo.m      Tests the MLDS with a data sample. Provides template for using the routines. 
% MLDSColorSimulationDemo.m     Simulates a set of responses for a series of hypothetical targets positioned 
%                               somewhere along the space of competitors and uses MLDS method to infer the 
%                               target position given the simulated set of responses. 
