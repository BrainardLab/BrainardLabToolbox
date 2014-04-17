function blob = GenGaussianBlob(borderColor, centerColor, pxSize, pxSigma)

if ~exist('pxSize', 'var') || isempty(pxSize), pxSize = 400; end
if ~exist('pxSigma', 'var') || isempty(pxSigma), pxSigma = 90; end

blob1 = zeros(pxSize, pxSize, 3);
blob2 = zeros(pxSize, pxSize, 3);

% Generate the 2D Gaussian.
x = CustomGauss([pxSize pxSize], pxSigma, pxSigma, 0, 0, 1, [0 0]);

for i = 1:3
	blob1(:,:,i) = borderColor(i) * (1 - x);
	blob2(:,:,i) = centerColor(i) * x;
end

blob = blob1 + blob2;
