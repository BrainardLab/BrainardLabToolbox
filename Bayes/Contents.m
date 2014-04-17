% BayesToolbox
%
% Set of routines for doing basic Bayesian estimation, collected up by
% model.
%
% Requires the statistics toolbox.
%
% Models - Each model is specified by its likelihood and prior.
%
%   BinomialBeta - Binomial data, beta prior. Currently just
%   a routine to compute beta parameters from mean and variance.
%
%     betaparamsfrommeanVar         - Compute beta a,b from mean and variance.
%
%   MvnNormal - Multivariate normal prior with known mean and
%   covariance.  Normal likelihood.  Allows for a linear
%   transformation between scene vector x and data vector y.  The
%   model is x~N(ux,Kx), y = T*x+n, n~N(un,Kn).  The solution for
%   this model is analytic, and the posterior p(x|y) is also Normal.
%
%    BayesMvnNormalExpectedSSE      - Expected SSE error from using posterior mean
%    BayesMvnNormalLikelihood       - Likelihood function
%    BayesMvnNormalNoiseDraw        - Draw from noise distribution.
%    BayesMvnNormalPosteriorCov     - Covariance of posterior.  Independent of data y.
%    BayesMvnNormalPosteriorDraw    - Draw from the posterior distribution.
%    BayesMvnNormalPosteriorMean    - Mean of the posterior
%    BayesMvnNormalPosteriorProb    - Analytic posterior prob
%    BayesMvnNormalPriorDraw        - Draw from prior    
%    BayesMvnNormalPriorProb        - Prior prob
%    BayesMvnNormalTest             - Test MvnNormal model routines
%
%   Cauchy - Univariate and multivariate support routines for the
%   Cauchy distribution.
%    cauchycdf                      - Cumulative distribution for univariate Cauchy
%    cauchypdf                      - Probability density function for univariate Cauchy
%
%   MvnPoiss - Multivariate normal prior with known mean and
%   covariance.  Positivity constraint on x.  Poisson likelihood.
%   Allows for a linear transformaiton between scen vector x and
%   data y, as well as a "dark noise" component in the Poisson noise.
%
%    BayesMvnPoissLikelihood        - Likelihood function
%    BayesMvnPoissPosteriorUnprob   - Unnormalized posterior probability
%    BayesMvnPoissPriorDraw         - Draw from prior    
%    BayesMvnPoissPriorUnprob       - Unnormalized prior prob
%
%   MvLogNormal - Multivariate log normal routines.  These are
%   currently just routines that compute distributional properties.
%
%    mvnlognpdf                     - PDF of multivariate log normal distribution
%    mvlognrnd                      - Generate draws
%    mvlognmeancovtonorm            - Convert parameters in log normal representation to underlying normal. 
%    mvlognmeancovfromnorm          - Convert parameters from to underlying normal to log normal representation. 
%
%   WienerEst - Support for space domain Wiener estimation.  See Brainard sampling tech report.
%    MakeRawWiener                  - Low level work routine for MakeWienerInterp
%    MakeWienerEst                  - Make the Wiener reconstruction matrices.
%    WienerEstDemo                  - Demonstrate use and properties of Wiener estimator
%                                     for simulated time series data.
%
%   Wishart - Wishart distribution support.
%    mvgammaln                      - Log multivariate gamma function.
%    wishpdf                        - Evaluate Wishart PDF.  Can also do inverse-Wishart, it looks like.
%    wishpdfln                      - Evaluate ln of the Wishart PDF.