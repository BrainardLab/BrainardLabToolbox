% ColorMaterialModel
%
% Routines that implement an MLDS style model for our color-material
% selection experiment.  Actually, there is nothing particularly specific
% to color and material, this is just a two-dimensional extension but with
% the restriction (for now) that stimuli lie on one axis or the other,
% without full mixtures being presented.


% ColorMaterialExampleStructure            - Example parameters structure defining number of stimuli etc.
% ColorMaterialModelComputeLogLikelihood   - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelComputeProb            - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelComputeProbTest        - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelComputeTradeOffPredictions - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelCrossValidation        - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelDemo                   - Demo program that fits the model to simulated or example data.
% ColorMaterialModelGetValuesFromFits      - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelParamsToX              - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelPlotFits               - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelSimulatedData          - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelSimulateResponse       - Various functions related to distributions and Bayesian calculations.
% ColorMaterialModelXToParams              - Various functions related to distributions and Bayesian calculations.
% ColorMaterialPlotSolution                - Various functions related to distributions and Bayesian calculations.
% FitColorMaterialModel                    - Use numerical search to fit the model.
% FitColorMaterialScalingConstraint        - Nonlinear constraint function for the MLDS-based model fitting.
% FitColorMaterialScalingFun               - Error function (what to minimize) for the MLDS-based model fitting.
% FitToColorMaterialTradeOffFun            - Error function (what to minimize) for the descriptive Weibull function fitting.
% pairIndices                              - Matrix describing competitor pairing in our initial experiment.
%                                            In the long run, this might come out of the toolbox itself.
% PlotsWithSavedParams                     - Various functions related to distributions and Bayesian calculations.
% SetColorMaterialModelExp1Params          - Various functions related to distributions and Bayesian calculations.


