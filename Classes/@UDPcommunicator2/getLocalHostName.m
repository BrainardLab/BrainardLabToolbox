function localHostName = getLocalHostName()
    systemInfo = GetComputerInfo();
    localHostName = lower(systemInfo.networkName);
end