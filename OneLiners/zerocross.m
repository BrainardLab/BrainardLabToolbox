function z=zerocross(v)
%
% Z = ZEROCROSS(V)
%
% Return the indices of changes in sign between components of the
% vector.
%
% >> A = randn([10 1])
%
% A =
%
%  -0.49840598306643
%   1.04975509964655
%  -1.67055867973620
%  -2.01437026154355
%   0.98661592496732
%  -0.06048256273708
%   1.19294080740269
%   2.68558025885591
%   0.85373360483580
%   1.00554850567375
%
% >> zerocross(A)
%
% ans =
%
%     2
%     3
%     5
%     6
%     7
%
  z=find(diff(v>0)~=0)+1;
  
