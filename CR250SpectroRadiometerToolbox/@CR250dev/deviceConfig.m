function deviceConfig(obj)

    showFullResponse = ~true;
    obj.retrieveDeviceInfo('RC ID', showFullResponse);
    obj.retrieveDeviceInfo('RC Model', showFullResponse);
    obj.retrieveDeviceInfo('RC InstrumentType', showFullResponse);
    obj.retrieveDeviceInfo('RC Firmware', showFullResponse);
    obj.retrieveDeviceInfo('RS Aperture', showFullResponse);
    obj.retrieveDeviceInfo('RC Aperture', showFullResponse);
    obj.retrieveDeviceInfo('RC Accessory', showFullResponse);
    obj.retrieveDeviceInfo('RC Filter', showFullResponse);
    obj.retrieveDeviceInfo('RC SyncMode', showFullResponse);

end
