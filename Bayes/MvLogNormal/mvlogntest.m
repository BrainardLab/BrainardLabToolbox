% mvnlogntest
%
% Test routines for our multivariate log normal distribution routines.
%
% 12/19/07  dhb, lyj  Wrote it.
% 12/23/07  dhb       Lots of work for new calling forms, and more tests.

%% Clear
clear; close all;

%% Test that we can go back and forth between the two parameterizations when
% there is no corrlation.
u_y = [2.1 3.2];
K_y = [1.3 0 ; 0 2.3];
[u_x,K_x,var_x] = mvlognmeancovtonorm(u_y,K_y);
[u_ycheck,K_ycheck,corr_y,corr_x] = mvlognmeancovfromnorm(u_x,K_x);
if ( any(abs(u_y-u_ycheck) > 1e-7) | any(abs(K_y-K_ycheck) > 1e-7) )
    fprintf('Error in parameter translation for diagonal covariance matrix\n');
else
    fprintf('Parameter translation OK for diagonal covariance matrix\n');
end

%% Test that we can go back and forth between the two parameterizations when
% there is correlation.
u_y = [2.1 3.2];
var_y = [1.3 2.3];
r = 0.7;
K_y = [1.3 r*sqrt(var_y(1)*var_y(2)) ; r*sqrt(var_y(1)*var_y(2)) 2.3];
[u_x,K_x,var_x] = mvlognmeancovtonorm(u_y,K_y);
[u_ycheck,K_ycheck,corr_y,corr_x] = mvlognmeancovfromnorm(u_x,K_x);
if ( any(abs(u_y-u_ycheck) > 1e-7) | any(abs(K_y-K_ycheck) > 1e-7) )
    fprintf('Error in parameter translation for general covariance matrix\n');
else
    fprintf('Parameter translation OK for general covariance matrix\n');
end

%% Test that we get right answer for 1d by comparing to stats toolbox
% function.  Note that our function and Matlab's have the same convention,
% call with parameters of the underying normal distribution.  This test
% is for no correlation between the two dimensions, which is the case
% where our intuitions about what should happen are reasonably strong.
u_y = [2.1 3.2];
K_y = [1.3 0 ; 0 2.3];
[u_x,K_x,var_x] = mvlognmeancovtonorm(u_y,K_y);
v = linspace(.01,10,1000)';
p_us1 = mvlognpdf(v,u_x(1),K_x(1,1));
p_us2 = mvlognpdf(v,u_x(2),K_x(2,2));
p_matlab1 = lognpdf(v,u_x(1),sqrt(K_x(1,1)));
p_matlab2 = lognpdf(v,u_x(2),sqrt(K_x(2,2)));
figure; clf; hold on
plot(v,p_us1,'r+');
plot(v,p_matlab1,'k');
plot(v,p_us2,'g+');
plot(v,p_matlab2,'k');

% Test that a one-d slice of a call to our routine in 2D matches up to a scale factor
v1 = [v , 0.01*ones(size(v))];
v2 = [0.01*ones(size(v)) , v];
p_us1 = mvlognpdf(v1,u_x,K_x);
p_us2 = mvlognpdf(v2,u_x,K_x);
p_matlab1 = lognpdf(v,u_x(1),sqrt(K_x(1,1)));
p_matlab2 = lognpdf(v,u_x(2),sqrt(K_x(2,2)));
figure; clf; hold on
plot(v,p_us1/max(p_us1(:)),'r+');
plot(v,p_matlab1/max(p_matlab1(:)),'k');
plot(v,p_us2/max(p_us2(:)),'g+');
plot(v,p_matlab2/max(p_matlab2(:)),'k');

%% Generate some random draws from an mvlogn distribution, and compare
% with expected parameters.  This also computes and plots the marginal
% pdfs and compares with histograms of the marginals.  The fact that
% the agreement is good is quite reassuring.
ndraws = 10000;
u_y = [2.1 3.2];
var_y = [1.3 2.3];
r = 0.5;
K_y = [1.3 r*sqrt(var_y(1)*var_y(2)) ; r*sqrt(var_y(1)*var_y(2)) 2.3];
[u_x,K_x,var_x] = mvlognmeancovtonorm(u_y,K_y);
x = mvlognrnd(u_x,K_x,ndraws);
u_ycheck = mean(x,1);
K_ycheck = cov(x);
fprintf('Mean 1 pred; %g, meas: %g\n',u_y(1),u_ycheck(1));
fprintf('Mean 2 pred; %g, meas: %g\n',u_y(2),u_ycheck(2));
fprintf('Variance 1 pred: %g, meas: %g\n',K_y(1,1),K_ycheck(1,1));
fprintf('Variance 2 pred: %g, meas: %g\n',K_y(2,2),K_ycheck(2,2));
fprintf('Covariance 12 pred: %g, meas %g\n',K_y(1,2),K_ycheck(1,2));

% Compute pdf over the range
rawvals = linspace(0,10,100);
binwidth = rawvals(2)-rawvals(1);
index = 1;
for i = 1:length(rawvals);
    for j = 1:length(rawvals);
        vals(index,1) = rawvals(i);
        vals(index,2) = rawvals(j);
        index = index+1;
    end
end
probs = mvlognpdf(vals,u_x,K_x);
for i = 1:length(rawvals)
    index = find(vals(:,1) == rawvals(i));
    marginals1(i) = sum(probs(index));
    index = find(vals(:,2) == rawvals(i));
    marginals2(i) = sum(probs(index));
end

% Plot
figure; clf;
subplot(1,2,1); hold on
hist(x(:,1),rawvals);
plot(rawvals,marginals1*binwidth^2*ndraws,'r','LineWidth',2);
axis([0 10 0 1000]);
subplot(1,2,2); hold on
hist(x(:,2),rawvals);
plot(rawvals,marginals2*binwidth^2*ndraws,'r','LineWidth',2);
axis([0 10 0 1000]);


%% Look at the result of draws.  Use this to play with lognormal parameters
% to produce desired distributional properties.  I found that 
%   u_param = 0.5; var_param = 0.2; r = 0.0; 
% produces something reasonable for surfaces, while
%   u_param = 30; var_param = 1000; r = 0.85;
% looks reasonable for illuminants for our staircase Gelb simulations
npixels = 11; ndraws = 10000;
u_param = 30; var_param = 1000; r = .85;
u_y = u_param*ones(1,npixels);
%u_y = [1 1 1 30 30 30 30 30 1 1 1 ];
var_y = var_param*ones(1,npixels);
%r = 0.0;
for i = 1:npixels
    for j = 1:npixels
        K_y(i,j) = r^(abs(i-j))*sqrt(var_y(i)*var_y(j));
    end
end
[u_x,K_x,var_x] = mvlognmeancovtonorm(u_y,K_y);
x = mvlognrnd(u_x,K_x,ndraws);
u_ycheck = mean(x,1);
K_ycheck = cov(x);
fprintf('Mean 1 pred; %g, meas: %g\n',u_y(1),u_ycheck(1));
fprintf('Mean 2 pred; %g, meas: %g\n',u_y(2),u_ycheck(2));
fprintf('Variance 1 pred: %g, meas: %g\n',K_y(1,1),K_ycheck(1,1));
fprintf('Variance 2 pred: %g, meas: %g\n',K_y(2,2),K_ycheck(2,2));
fprintf('Covariance 12 pred: %g, meas %g\n',K_y(1,2),K_ycheck(1,2));

figure; clf;
subplot(1,3,1);
hist(x(:,1),linspace(0,u_param+3*sqrt(var_param),100));
axis([0 u_param+3*sqrt(var_param) 0 ndraws/10]);
subplot(1,3,2);
hist(x(:,2),linspace(0,u_param+3*sqrt(var_param),100));
axis([0 u_param+3*sqrt(var_param) 0 ndraws/10]);
subplot(1,3,3)
plot(x(:,1),x(:,2),'r+'); axis('square');
axis([0 max([x(:,1) ; x(:,2)]) 0 max([x(:,1) ; x(:,2)]) ]);
mvlognRndPlot(u_y, K_y, ndraws, u_param, var_param);
