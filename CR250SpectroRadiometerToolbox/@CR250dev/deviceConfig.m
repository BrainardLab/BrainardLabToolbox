function deviceConfig(obj)

    showFullResponse = ~true;
    obj.getDeviceInfo('RC ID', showFullResponse);
    obj.getDeviceInfo('RC Model', showFullResponse);
    obj.getDeviceInfo('RC InstrumentType', showFullResponse);
    obj.getDeviceInfo('RC Firmware', showFullResponse);
    obj.getDeviceInfo('RS Aperture', showFullResponse);
    obj.getDeviceInfo('RC Aperture', showFullResponse);
    obj.getDeviceInfo('RC Accessory', showFullResponse);
    obj.getDeviceInfo('RC Filter', showFullResponse);
    obj.getDeviceInfo('RC SyncMode', showFullResponse);

end
