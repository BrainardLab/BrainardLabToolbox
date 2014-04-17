function [imageInfo,infoStr] = GetNEFInfo(imageName,useDcraw,ext)
% [imageInfo,infoStr] = GetNEFInfo(imageName,[useDcraw],[ext])
%
% Parse the header info returned by the exiftool function and return
% as fields of a structure.
%
% Assumes exiftool is installed and on the UNIX path seen by MATLAB.
%   http://www.sno.phy.queensu.ca/~phil/exiftool/
%
% The application dcraw can get a subset of the info that exiftool
% can.  You can use it too by passing the second argument as 1.  But
% some fields will not be set meaningfully in this case. 
%  http://www.cybercom.net/~dcoffin/dcraw/
%
% This works for the one image I tried.  May not be totally robust,
% depending on how much variation there is for info string returned
% by for different images (or by different versions of exiftool/dcraw.)
%
% Returned fields.
%
% exiftool and dcraw
%   exposure          exposure duration in seconds
%   fStop             aperture f-stop
%   focalLength       lens focal length in mm
%
% exiftool only:
%   serialNumber      camera serial number
%   whichCamera       gives a lab name for each camera we know about
%                     ('standard','auxiliary','unknown')
%   focusMode         focus mode string. AF-S and AF-C are autofocus, I think.
%
% 1/21/10  dhb  Wrote it.
% 1/24/10  dhb  exiftool gets more info, use this.
% 4/21/10  dhb  Add ISO so that we can correct for it later.
% 7/7/10   dhb, gt, pg  Return auxilliary camera data name.
% 8/1/10   dhb  Alow passing extension.
%               Handle fact that CR2 images don't have a serial number
% 1/3/11   dhb  Focus mode

if (nargin < 2 || isempty(useDcraw))
     useDcraw = 0;
end

if (nargin < 3 || isempty(ext))
     ext = 'NEF';
end

if (~useDcraw)
    
    exifCmd = ['exiftool ' imageName '.' ext];
    [status,infoStr] = unix(exifCmd);
    
    % Exposure duration
    theFieldstr = regexp(infoStr,'Exposure Time[\s]*:[\s]*[0-9\./]*','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\./]*','match');
    imageInfo.exposure = eval(theFieldstr{1});
    
    % fStop
    theFieldstr = regexp(infoStr,'F Number[\s]*:[\s]*[0-9\.]*','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\.]*','match');
    imageInfo.fStop = eval(theFieldstr{1});
    
    % ISO
    theFieldstr = regexp(infoStr,'ISO[\s]*:[\s]*[0-9\.]*','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\.]*','match');
    imageInfo.ISO = eval(theFieldstr{1});
    
    % Lens focal length
    theFieldstr = regexp(infoStr,'Focal Length[\s]*:[\s]*[0-9\.]*','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\.]*','match');
    imageInfo.focalLength = eval(theFieldstr{1});
    
    % Camera serial number and name
    theFieldstr = regexp(infoStr,'Serial Number[\s]*:[\s]*No=\s[a-zA-Z0-9\.]*','match');
    if (length(theFieldstr) == 0) %#ok<ISMT>
        imageInfo.serialNumber = '';
        imageInfo.whichCamera = 'unknown';
        imageInfo.cameraData = [];
    else
        theFieldstr = regexp(theFieldstr{1},'[0-9][a-zA-Z0-9\.]*','match');
        imageInfo.serialNumber = theFieldstr{1};
        switch (imageInfo.serialNumber)
            case '2000a9a7'
                imageInfo.whichCamera = 'standard';
                imageInfo.cameraData = 'StandardD70Data';
            case '20004b72'
                imageInfo.whichCamera = 'auxiliary';
                imageInfo.cameraData = 'AuxilliaryD70Data';
            otherwise
                imageInfo.whichCamera = 'unknown';
                imageInfo.cameraData = [];
        end
    end
    
    % Focus mode
    theFieldstr = regexp(infoStr,'Focus Mode[\s]*:[\s]*\s[a-zA-Z0-9\.\-]*','match');
    if (length(theFieldstr) == 0) %#ok<ISMT>
        imageInfo.focusMode = '';
    else
        theFieldstr = regexp(theFieldstr{1},'[a-zA-Z0-9\.\-]*','match');
        imageInfo.focusMode = theFieldstr{3};
    end
    
    % Light value
    theFieldstr = regexp(infoStr,'Light Value[\s]*:[\s]*\s[a-zA-Z0-9\.\-]*','match');
    if (length(theFieldstr) == 0) %#ok<ISMT>
        imageInfo.lightValue = [];
    else
        theFieldstr = regexp(theFieldstr{1},'[a-zA-Z0-9\.\-]*','match');
        imageInfo.lightValue = eval(theFieldstr{3});
    end
    
% Here is the old dcraw version   
else
    % Get the info via dcraw
    dcrawCmd = ['dcraw -i -v ' imageName '.' ext];
    [status,infoStr] = unix(dcrawCmd);
    
    % Now parse the string
    theFieldstr = regexp(infoStr,'Shutter:\s[0-9\./]*\ssec','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\./]*','match');
    imageInfo.exposure = eval(theFieldstr{1});
    
    % Now parse the string
    theFieldstr = regexp(infoStr,'Aperture:\sf/[0-9\.]*','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\.]*','match');
    imageInfo.fStop = eval(theFieldstr{1});
    
    % Now parse the string
    theFieldstr = regexp(infoStr,'Focal length:\s[0-9\.]*\smm','match');
    theFieldstr = regexp(theFieldstr{1},'[0-9\.]*','match');
    imageInfo.focalLength = eval(theFieldstr{1});
    
    % Serial number, camera name
    imageInfo.serialNumber = '';
    imageInfo.whichCamera = 'unknown';
end



