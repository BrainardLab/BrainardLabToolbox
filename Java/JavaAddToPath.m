function JavaAddToPath(thePath,theMsg)
% JavaAddToPath(thePath,theMsg)
%
% Add thePath to the java dynamic path.  Print a message
% if theMsg is passed and not empty.  String theMsg should
% identify which jave path is being worked on.
%
% Does a number of check to try to prevent barfing in cases
% where thePath does not exist, etc.  And, doesn't add if
% it is already there.
%
% Our primary use for this is in our startup.m file.
%
% 6/20/13  dhb  Factorized out of startup.m

% Check args
if (nargin < 2)
    theMsg = [];
end

% Make sure the version of Matlab has javaaddpath, do nothing if not.
[~,theLib,jarExt] = fileparts(thePath);
theFile = [theLib '.' jarExt];
if (exist('javaaddpath','file'))
    % Get current path and check if requested path is already there
    javapath = javaclasspath('-all');
    needToAdd = true;
    for i = 1:length(javapath)
        if (any(strfind(javapath{i},theFile)))
            if (~isempty(theMsg))
                fprintf('%s is already on the java path\n',thePath);
            end
            needToAdd = false;
            break;
        end
    end
    
    %% Need to add
    if (needToAdd)
        if (~exist(thePath))
            if (~isempty(theMsg))
                fprintf('Cannot add %s to the java path because it is not present on your computer\n',theMsg);
            end
        else
            if (~isempty(theMsg))
                fprintf('Adding %s to the java path\n',theMsg);
            end
            javaaddpath(thePath);
        end
    end
else
    if (~isempty(theMsg))
        fprintf('Cannot add %s to the java path because your version of Matlab is too old\n',theMsg);
    end
end
            