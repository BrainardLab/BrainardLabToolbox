function [dip, pValue, xlow, xup, bootDip] = HartigansDipBootstrap(xSamples, nBoot);
%function [dip, pValue, xlow, xup, bootDip] = HartigansDipBootstrap(xSamples,
%nBoot);
%
% Output:
%       dip - dip statistic pValue
%
% NOTE: The original code was obtained from the WWW; the copyright status
% is not clear. As of 3/16/2013, the code can be obtained from
% http://www.nicprice.net/diptest/hartigansdipsigniftest.m.
%
% Original documentation (added verbatim):
%
% "calculates Hartigan's DIP statistic and its significance for the
% empirical p.d.f  XPDF (vector of sample values) This routine calls the
% matlab routine 'HartigansDipTest' that actually calculates the DIP NBOOT
% is the user-supplied sample size of boot-strap Code by F. Mechler (27
% August 2002)"
%
% 3/16/2013     spitschan       Included in toolbox, commented code.

% Calculate the dip statistic from the samples 
[dip, xlow, xup] = HartigansDipTest(xSamples);
nSamples = length(xSamples);

% Calculate a bootstrap sample (sampling uniformly from original data set)
bootDip = [];
for i = 1:nBoot
   % Take a bootstrap sample
   bootstrapSamples = sort(unifrnd(0,1,1,nSamples));
   [tmpDip] = HartigansDipTest(bootstrapSamples);
   bootDip = [bootDip; tmpDip];
end;

% Sort the bootstrapped dip statistics
bootDip = sort(bootDip);

% Calculate the empirical p value
pValue = sum(dip < bootDip)/nBoot;