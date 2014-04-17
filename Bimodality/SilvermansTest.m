function [m, p] = SilvermansTest(data, nBoot, max_k)
%function [m, p] = SilvermansTest(data)
%
% Performs Silverman's test for modality.
%
% This was at http://avocado.caltech.edu/klemens some time ago (see
% archive.org)
%
% 3/16/2013     spitschan       Included in toolbox, commented code.

% Define some parameters for h
h_scale=.0001;
h_min=.01;
h_max=3;

% Find scales
[modect_scale, modect_min, modect_max] = setvars(data);

% Find the map from smooth parameter h to number of mode found
m = map_h_to_k(data,h_scale,h_max,h_min,modect_scale,modect_min,modect_max);


% Produce a significance table
p = produce_p_table(data,m,max_k,modect_scale,modect_min,modect_max,nBoot);


function d = boot_draw(data)
%function d = boot_draw(data)
% Draw a bootstrap sample
nSamples = length(data);
r = randi([1 nSamples], 1, nSamples);
d = data(r);

function modect = countmodes(in,h,modect_scale,modect_min,modect_max)
%function modect = countmodes(in,h,modect_scale,modect_min,modect_max)
% Count the number of modes
scale = modect_min:modect_scale:modect_max;

% Number of modes detected
modect = 0;

ddd = zeros(length(scale),2);
ddd(:,1) = scale';
for i = 1:length(scale)
    ddd(i,2) = sum(normpdf((ddd(i,1)-in(1,:))./h))./(h*length(scale));
end

for i = 3:length(scale)
    if(ddd(i,2) <= ddd(i-1,2) && ddd(i-1,2) > ddd(i-2,2))
        modect = modect+1;
    end
end

function p = boot(data,h0,modect_target,modect_scale,modect_min,modect_max,nBoot)
%function p = boot(data,h0,modect_target,modect_scale,modect_min,modect_max,nBoot)
p = 0;
for i=1:nBoot
    if(countmodes(boot_draw(data),h0,modect_scale,modect_min,modect_max) <= modect_target)
        p = p+1;
    end
end
    p = p/nBoot;

function map = map_h_to_k(data,h_scale,h_max,h_min,modect_scale,modect_min,modect_max)
%function map=map_h_to_k(data,h_scale,h_max,h_min,modect_scale,modect_min,modect_max)
hs = h_min:h_scale:h_max;
for i = 1:length(hs)
    map(i,1) = hs(i);
    map(i,2) = countmodes(data,hs(i),modect_scale,modect_min,modect_max);
end


function htab = produce_h_table(data,htokmap,max_k)
%function htab = produce_h_table(data,htokmap,max_k)
for i=1:max_k;
    htab(i, 1) = i;
    htab(i, 2) = min(htokmap(htokmap(:,2)==i,1));
end


function ptab=produce_p_table(data,htokmap,max_k,modect_scale,modect_min,modect_max,nBoot)
%function ptab=produce_p_table(data,htokmap,max_k,modect_scale,modect_min,modect_max,nBoot)
htab=produce_h_table(data,htokmap,max_k);
for i=1:max_k
    ptab(i, 1)= i;
    ptab(i, 2) = boot(data,htab(i,2),htab(i,1),modect_scale,modect_min,modect_max,nBoot);
end


function [modect_scale, modect_min, modect_max] = setvars(data)
%function [modect_scale, modect_min, modect_max] = setvars(data)
m1 = max(data);	%rescale based on the data.
m2 = min(data);

modect_scale = (m1 - m2)/200;
modect_min = m2 - (m1-m2)/10;
modect_max = m1 + (m1-m2)/10;