function OOC_checkCR250(varargin)

    if (nargin == 0)
        verb = 1;
    else
        verb = varargin{1};
        if (isnumeric(verb) && verb >= 0 && verb <= 10)
        else
            verb = 1;
        end
    end

    CR2550obj = [];
    
    try
        CR2550obj = CR250dev(...
                'verbosity',        verb, ...    % 1 -> minimum verbosity
                'devicePortString', [] ...       % empty -> automatic port detection)
                );
        fprintf('<strong>Hit enter to close device: </strong>');
        pause
        fprintf('Please wait ...');
        CR2550obj.shutDown();
        
    catch err
        fprintf('<strong>\nEncountered the following error: %s</strong>\n', err.message);
        if (~isempty(CR2550obj))
            CR2550obj.shutDown();
        end
        rethrow(err);
    end
    
end
