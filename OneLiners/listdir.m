function [outList] = listdir(inputdir,type)

% Lists the contents of a directory
%
%   Usage:
%
%   [outlist] = listdir(inputdir,type)
% 
%   Inputs:
%       inputdir = path to input directory
%       type = 
%           'files' to create a list of files in <inputdir>
%           'dirs' to create a list of directories in <inputdir>
%
%   Output: list of directory contents, based on type
%
%   Written by Andrew S Bock Feb 2014

D = dir(inputdir);
% remove hidden files from the list
isHidden = strncmp('.',{D(:).name}',1); 
D(isHidden) = [];
% Find directories 
dirList = cell2mat({D(:).isdir}'); % '1' if dir, '0' if not
% Sort by type desired (directory list vs file list)
if strcmp(type,'files')
    D(dirList) = [];
    outList = {D(:).name};    
elseif strcmp(type,'dirs')
    D(dirList==0) = [];
    outList = {D(:).name};  
else
    disp('missing "type" input')
end
% transpose output for ease of viewing
outList = outList';
