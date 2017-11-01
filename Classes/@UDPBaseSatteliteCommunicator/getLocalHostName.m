function localHostName = getLocalHostName()
    systemInfo = GetComputerInfo();
    localHostName = lower(systemInfo.networkName);
    k = strfind(localHostName, '.');
    localHostName = lower(localHostName(1:k-1));
end