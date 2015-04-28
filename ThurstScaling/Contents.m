% ThurstScaling
%
% Routines developed to perform Thurstonian Scaling, or at least something
% much like it based on a quick read of the underlying ideas.
%
% Based on our MLDSColorSelection code.
%
% ROUTINES
%
% ThurstScaling.m -             Main fitting routine. 
% ThurstScalingComputeLogLikelihood.m - Computes log likelihood for a current fit. 
% ThurstScalingComputeProb.m -  Based on current fits, it computes probability that one element of
%                               the pair is going to be chosen as closer to the target based on current
%                               Can be used for debugging purposes when certain data pattern fit fails. 
% ThurstScalingPlot.m -         Plots the results of Thustonian Scaling fit: the inferred
%                               positions of the stimuli are plotted.
%
% TEST/DEMO
% ThurstScalingSimulationDemo.m - Tests the MLDS with a data sample. Provides template for using the routines. 

