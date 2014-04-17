function im = GenCircle(circleColor, bgColor)
if nargin ~= 2
    error('Usage: im = GenCircle(circleColor, bgColor)');
end

% Make sure that the colors are RGBA format.
x = size(circleColor);
if x(1) ~= 1 || x(2) ~= 4
    error('circleColor must me in RGBA format.');
end
x = size(bgColor);
if x(1) ~= 1 || x(2) ~= 4
    error('bgColor must me in RGBA format.');
end

im = ones(258, 258, 4);

% Set the background color.
for i = 1:4
    im(:,:,i) = bgColor(i);
end

r = 258/2;
x = linspace(-r, r, r*2);
y = sqrt(r^2 - x.^2);
y = round(y/max(y)*128);

for i = 1:length(x)
    yt = y(i)+r+1;
    yb = -y(i)+r;
 
    for j = 1:4
        im(yb:yt, i, j) = circleColor(j);
    end
end

im = im(2:end-1, 2:end-1, :);
