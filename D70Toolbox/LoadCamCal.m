function Cam_Cal = LoadCamCal(camera_type)
    switch(camera_type)
        case 'standard'
            load('StandardD70Data');
        case 'auxiliary'
            load('AuxiliaryD70Data');
        otherwise
            error('Unknown camera specified');
    end
end