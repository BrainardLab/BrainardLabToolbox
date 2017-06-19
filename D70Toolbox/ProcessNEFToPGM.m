% ProcessNEFToPGM
%
% This proceeses NEF files from our NIKON D70
% and converts them to PGM.  This can be read
% by MATLAB for further processing.
%
% See also
%  ProcessPGMToMat
%
% 9/27/05   dhb, pbg      Wrote it by lobotomizing scale_ppm.m
% 01/21/10  dhb, ar       Modified from a previous test program.
% 01/22/10  dhb           Getting better.
% 01/25/10  dhb           Merge with old nef_to_ppm.m file, to process directory.
% 01/28/10  dhb, ar       Explicitly call v571, which is like what we used to calibrate
% 01/28/10  dhb, ar       Remove bigD/litleD check.  Now have separate dcraw test program.
% 01/28/10  cb, ar        Added a command to call the specified directory.
% 06/25/10  gt            Changed into a function.
% 12/31/10  dhb           Optional dcrawversion.
% 6/18/17   dhb           Use fullfile to create dcraw command.


function ProcessNEFToPGM(silent, path, dcrawpath, dcrawversion)
    if (nargin == 0 || isempty(silent))
        silent = 0;
    end
    if (nargin < 3 || isempty(dcrawpath))
        dcrawpath = '';
    end
    if (nargin < 4 || isempty(dcrawversion))
        dcrawversion = 'v571';
    end
    
    

    %% List NEF files of given directory
    if (silent==0)
        defaultAnswer = pwd;
        thePrompt = sprintf('Enter the name of the NEF image directory [%s]: ',defaultAnswer);
        theDirectory = input(thePrompt,'s');
        if (isempty(theDirectory))
            theDirectory = defaultAnswer;
        end
    else
        theDirectory = path;
    end
    
    fprintf('Image directory is %s\n',theDirectory);

    % Creates a text document with the name and location of all NEF files
    fileSpec = [theDirectory, filesep, '*.NEF'];
    theFiles = dir(fileSpec);

    for f = 1:length(theFiles)
        [nil,filename] = fileparts(theFiles(f).name);
        filename = sprintf('%s/%s', theDirectory, filename);
        fprintf('\tProcessing file %s\n',filename);
        unix(['rm -rf ' filename '.ppm ' filename '.d.pgm ' filename '.D.pgm']);

        % Get exposure duration, etc
        imageInfo(f) = GetNEFInfo(filename); %#ok<*SAGROW>
        fprintf('\t\tCamera: %s\n',imageInfo(f).whichCamera);
        fprintf('\t\tExposure %g\n',imageInfo(f).exposure);
        fprintf('\t\tfStop %g\n',imageInfo(f).fStop);
        fprintf('\t\tISO %g\n',imageInfo(f).ISO);

        % Use dcraw to conver the image to raw PGM format
        dcrawCmd = [fullfile(dcrawpath,['dcraw.' dcrawversion]) ' -4 -d ' filename '.NEF'];
        unix(dcrawCmd);
        
        % For the record, create a text file that has dcraw's view of what version
        % it was.
        dcrawVerCmd = [fullfile(dcrawpath,['dcraw.' dcrawversion]) ' >& ' filename '.dcrawverinfo.txt'];
        unix(dcrawVerCmd);

        % Space
        fprintf('\n');
    end

end