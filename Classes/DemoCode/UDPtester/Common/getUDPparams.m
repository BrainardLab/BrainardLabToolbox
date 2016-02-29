function params = getUDPparams()
    
    selection = input(sprintf('One light room (1) or Nicolas'' office ?'));
    if (selection == 1)
        configuration = 'OneLightRoom';
    else
        configuration = 'NicolasOffice'; 
    end
    
    switch configuration
        case 'OneLightRoom'
            params.macHostIP = '130.91.72.120';
            params.winHostIP = '130.91.74.15';
            params.udpPort = 2007;
            
        case 'NicolasOffice'
            params.winHostIP = '130.91.72.17';  % IoneanPelagos
            params.macHostIP = '130.91.74.10';  % Manta
            params.udpPort = 2007;
        otherwise
            error('Unknown configuration: ''%s''.', configuration);
    end
end

