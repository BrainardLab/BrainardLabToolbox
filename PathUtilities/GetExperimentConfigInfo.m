function [configFileDir,configFileName,dataDir,protocolList,protocolIndex,conditionName,stimulusDir] = GetExperimentConfigInfo(baseDir,mFileName,dataRootDir)
% [configFileDir,configFileName,dataDir,protocolList,protocolIndex,conditionName,,stimulusDir] = GetExperimentConfigInfo(baseDir,mFileName,dataRootDir)
%
% Interface with user to get top level configuration info for the standard BrainardLab experimental code
% setup.  Reads a top level tab delimited configuration file and prompts user to choose one of the
% conditions listed therein.
%
% The top level configuration file contains a row for each condition.  The allowable fields are:
%   conditionName (optional)    -- name that allows grouping of conditions.  Returned as empty if not specified.
%   name                        -- name of each condition.
%   configFile                  -- name of configuration file for the condition.
%   driver                      -- driver to call for the condition
%   dataDirectory               -- top level data directory for the condition.
%   stimulusRootDir             -- top level directory for the stimuli.
%   
% The routine returns
%   configFileDir               -- name of top level directory containing configuration file.
%                               -- this is fullfile(basedir,'config','').
%                               -- it's not clear why you'd ever need to use this, but kept for backwards compatibility.
%   configFileName              -- full path to the condition configuration file
%                               -- this is fullfile(baseDir,conditionName,configFile,'');
%   dataDir                     -- this is fullfile(dataRootDir,conditionName,protocolList(protocolIndex).dataDirectory,'');
%   protocolList                -- the structArray containing everything in the configuration file
%   protocolIndex               -- the index of the user choosen condition
%   condtionName                -- the condition name
%   stimulusDir                 -- this is fullfile(stimulusRootDir,conditionName,'');
%
% NOTE: This routine developed over time and is not perfectly designed.  When I (DHB) added conditionName 
% and stimulusRootDir fields, I kept backwards compatibility to the way this was done without these.
%
% 8/19/12  xxx   Pull out as function.
% 6/23/13  dhb   Add stimulusRootDir and conditionName returns
% 6/25/13  dhb   Add the trialing '.cfg' to the condition configuration file name if it isn't there already.


%% Directory where we expect the top level configuration file to be
configFileDir = fullfile(baseDir,'config','');

% Read the protocol list.
protocolListFileName = sprintf('%s/%sProtocols.cfg', configFileDir, mFileName);
protocolList =  ReadStructsFromText(protocolListFileName);
numProtocols = length(protocolList);

% Display a list of what protocols are available and have the user select
% one by number.
while true
	fprintf('\n- Available protocols\n\n');
	
	for i = 1:numProtocols
		fprintf('%d - %s\n', i, protocolList(i).name);
	end
	fprintf('\n');
	
	protocolIndex = GetInput('Choose a protocol number', 'number', 1);
	
	% If the user selected a protocol in the range of available protocols,
	% break out of the loop.  Otherwise, display the protocol list again.
	if any(protocolIndex == 1:numProtocols)
		break;
	else
		disp('*** Invalid protocol selected, try again.');
	end
end


% Optional field conditionName
if (isfield(protocolList(protocolIndex),'conditionName'))
    conditionName = sprintf('%s', protocolList(protocolIndex).conditionName);
else
    conditionName = [];
end

% Optional field stimulusRoot, leads to stimulusDir returned
if (isfield(protocolList(protocolIndex),'stimulusRootDir'))
    stimulusRootDir = sprintf('%s', protocolList(protocolIndex).stimulusRootDir);
else
    stimulusRootDir = [];
end

% Set the config file name for this protocol.  Paste on '.cfg' if it isn't
% already there.
configFileName = fullfile(configFileDir,conditionName,protocolList(protocolIndex).configFile);
[~,~,ext] = fileparts(configFileName);
if (isempty(ext))
    configFileName = [configFileName '.cfg'];
end

% Set the path to where the protocol's data will be stored.
dataDir = fullfile(dataRootDir,conditionName,protocolList(protocolIndex).dataDirectory,'');

% Set the path to where the stimuli will be found
stimulusDir = fullfile(stimulusRootDir,'stimuli',conditionName,'');


