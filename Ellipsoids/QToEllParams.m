function ellParams = QToEllParams(Q)
% ellParams = QToEllParams(Q)
%
% Take a positive-definite symmatrix matrix Q and convert it to the six
% parameters of an ellipsoid, in the ellParams form of three scalars and
% three euler angles, as one column vector.
%
% The parameterization of Q follows that in 
%   Poirson AB, Wandell BA, Varner DC, Brainard DH. 1990. Surface
%   characterizations of color thresholds. J. Opt. Soc. Am. A 7: 783-89.
% See particularly pp. 784-785.
%
% Notice that the may recover the scalar prameters in a different order than
% we put them in with, so that creating Q from ellParams and then recovering
% the ellParams vector can lead to two different parameter vectors.  What is 
% preserved is that both paramter vectors lead to the same Q. 
%
% This ambiguity doesn't both us, in part because it is not clear we really
% need this routine for any serious purpose -- the parameter vectors are
% just for the search routines, and we don't really ever need to get them
% back once we have Q.
%
% 07/04/16  dhb  Wrote it.
% 08/16/18  dhb  Change parameterization to match paper.

[~,S,V] = svd(Q);
scalers = diag(sqrt(S))';
eul = rotm2eul(V);

ellParams = [scalers  eul]';
[~,~,QCheck] = EllipsoidMatricesGenerate(ellParams);
if (max(abs(QCheck(:)-Q(:))) > 1e-8)
    error('Cannot recover ellipsoid parameters from Q');
end