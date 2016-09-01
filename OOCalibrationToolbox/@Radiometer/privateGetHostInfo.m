% Method to get SVN, matlab, and computer info
function hostInfo = privateGetHostInfo(obj)
    if (obj.verbosity > 9)
                fprintf('In Radiometer.hostInfo() method\n');
    end
    a = GetBrainardLabStandardToolboxesSVNInfo;
    hostInfo.svnInfo      = a.svnInfo;
    hostInfo.matlabInfo   = a.matlabInfo;
    hostInfo.computerInfo = GetComputerInfo;
end
