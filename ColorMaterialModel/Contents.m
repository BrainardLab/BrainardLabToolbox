% ColorMaterialModel
%
% Routines that implement an MLDS style model for our color-material
% selection experiment.  Actually, there is nothing particularly specific
% to color and material, this is just a two-dimensional extension but with
% the restriction (for now) that stimuli lie on one axis or the other,
% without full mixtures being presented.
%
% ColorMaterialModelBuildLookupTable.m     - Build a 5-dimensional lookup table of probabilities. 
% ColorMaterialModelComputeLogLikelihood   - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelComputeProb            - Compute probability of responses for MLDS-based model.
% ColorMaterialModelComputeProbTest        - Tests that ColorMaterialModelComputeProb works as we expect.
% ColorMaterialModelComputeWeibullProb     - Compute probability of responses for descriptive Weibull model
% ColorMaterialModelCrossValidation        - Demo program for cross-validating MLDS fits.
% ColorMaterialModelDemo                   - Demo program that fits the model to simulated or example data.
% ColorMaterialModelParamsToX              - Unpack parameters for MLDS-based model to a vector for search.
% ColorMaterialModelPlotFit                - Make a nice plot of either Weibull or MLDS-based model fit
% ColorMaterialModelPlotFitNoData          - Plots the color-material MLDS model fit without the data. 
% ColorMaterialModelPlotSolution           - Make all sorts of nice plots of the data and the MLDS solution. 
% ColorMaterialModelSimulateResponse       - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelXToParams              - Pack the vector of MLDS-based model parameters into structure.
% FitColorMaterialModelMLDS                - Use numerical search to fit the model.
% FitColorMaterialModelMLDSConstraint      - Nonlinear constraint function for the MLDS-based model fitting.
% FitColorMaterialModelMLDSFun             - Error function (what to minimize) for the MLDS-based model fitting.
% FitColorMaterialModelWeibull             - Fit the descriptive Weibull model to data.
% FitColorMaterialWeibullFun               - Error function (what to minimize) for the descriptive Weibull function fitting.
% LookupTable-cityblock.mat                - Computed cityblock lookup table, can be used to build interpolated versions (below)
% LookupTable-euclidean.mat                - Computed euclidean lookup table, can be used to build interpolated versions (below)
% colorMaterialInterpolateFunCubiceuclidean.mat  - cubic interpolation of the current probabilities lookup table based on euclidean distances. 
% colorMaterialInterpolateFunLineareuclidean.mat - linear interpolation of the current probabilities lookup table based on euclidean distances. 
% colorMaterialInterpolateFunCubiccityblock.mat  - cubic interpolation of the current probabilities lookup table based on cityblock distances. 
% colorMaterialInterpolateFunLinearcityblock.mat - cubic interpolation of the current probabilities lookup table based on cityblock distances. 

% PlotGriddedInterpolation.m                 - make movies of probabilities interpolated from the look up table three dimensions of the time.  

% ColorMaterialModelGetProbabilityFromLookupTable.m - get probability from the lookup table. Oneliner. 
%                                                     In the model code we use the one-line call rather than calling this function. 



