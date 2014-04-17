function theMean = blkmean2(theblockstruct)
% theMean = blkmean2(theblockstruct)
%
% Take the two dimensional mean of a block.  Had to write this to get blockproc to work.
%
% 5/18/10  dhb, gt  Wrote it.

theMean = mean2(theblockstruct.data);

end