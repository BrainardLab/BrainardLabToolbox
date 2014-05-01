% Method to combine svnInfo and matlabInfo into a single struct
% as was done in the old-style format
function  [svnInfo, svnInfoPath] = makeOldStyleSVNInfo(obj)
    svnInfo = struct;
    [svnInfo.svnInfo, svnInfoPath] = obj.retrieveFieldFromStruct('describe', 'svnInfo');
    [svnInfo.matlabInfo, svnMatlabPath] = obj.retrieveFieldFromStruct('describe', 'matlabInfo');  
end
