function DrawDisk(innerRadius, outerRadius, slices, loops, startAngle, endAngle)
if nargin ~= 6
    error('Invalid number of inputs');
end

% Make a new quaddric object and make sure it was allocated correctly.
thingy = gluNewQuadric;
if thingy == 0
    error('*** DrawDisk: Could not allocate memory for a quadric element');
end

% Draw the disk then delete the quadric.
gluPartialDisk(thingy, innerRadius, outerRadius, round(slices), round(loops), startAngle, endAngle);
gluDeleteQuadric(thingy);
