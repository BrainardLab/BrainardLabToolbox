% ColorMaterialModel
%
% Routines that implement an MLDS style model for our color-material
% selection experiment.  Actually, there is nothing particularly specific
% to color and material, this is just a two-dimensional extension but with
% the restriction (for now) that stimuli lie on one axis or the other,
% without full mixtures being presented.
%
% ColorMaterialExampleStructure            - Example parameters structure defining number of stimuli etc.
% ColorMaterialExampleStructureMake        - Produce the example parameters structure ColorMaterialExampleStructure.
% ColorMaterialModelComputeLogLikelihood   - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelComputeProb            - Compute probability of responses for MLDS-based model.
% ColorMaterialModelComputeProbTest        - Tests that ColorMaterialModelComputeProb works as we expect.
% ColorMaterialModelComputeWeibullProb     - Compute probability of responses for descriptive Weibull model
% ColorMaterialModelCrossValidation        - Demo program for cross-validating MLDS fits.
% ColorMaterialModelDemo                   - Demo program that fits the model to simulated or example data.
% ColorMaterialModelParamsToX              - Unpack parameters for MLDS-based model to a vector for search.
% ColorMaterialModelPlotMLDSFit            - Make a nice plot of the MLDS-based model fit
% ColorMaterialModelPlotWeibullFit         - Make a nice plot of the descriptive Weibull fit.
% ColorMaterialModelSimulatedData          - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelSimulateResponse       - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelXToParams              - Pack the vector of MLDS-based model parameters into structure.
% FitColorMaterialModelMLDS                - Use numerical search to fit the model.
% FitColorMaterialModelMLDSConstraint      - Nonlinear constraint function for the MLDS-based model fitting.
% FitColorMaterialModelMLDSFun             - Error function (what to minimize) for the MLDS-based model fitting.
% FitColorMaterialModelWeibull             - Fit the descriptive Weibull model to data.
% FitColorMaterialWeibullFun               - Error function (what to minimize) for the descriptive Weibull function fitting.
% pairIndices                              - Matrix describing competitor pairing in our initial experiment.
%                                            In the long run, this might come out of the toolbox itself.
% PlotsWithSavedParams                     - Temporary Ana routine that does something and will go away.


