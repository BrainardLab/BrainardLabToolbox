function findNonSuppressedOutput( p, considerPath )
% finds, based on profile data, lines of code which produce non-suppressed output
% (not terminated by semicolon). Useful to find annoying output in large programs
% consisting of many files. Only functions which are actually called are considered.
%
% to use:
% profile on; YourFunct(a,b,c); profile off;
% p=profile('info');
% findNonSuppressedOutput( p, '/code/projectA/' )
%
% this will run mlint on all called functions in path /code/projectA/ (and subdirs)
% and report lines that contain the requested mlint IDs (here: non-terminated lines)
% functions called that reside outside the provided path are ignored.
%
% Call as findNonSuppressedOutput( p, pwd ) to run in current directory.
%
%April 2009, ueli rutishauser, urut@caltech.edu - released under BSD license.
%March 2014, got this from Matlab central, added to BrainardLabToolbox.  

IDsToCatch = { 'NOPRT', 'NOPTS' }; %list of mlint IDs to find in all functions called

funcTable = p(1).FunctionTable;
n=length(funcTable);

disp('Files that have entries that dont supress output:');
for k=n:-1:1   
    fName = funcTable(k).FileName;
    if ~isempty( strfind( fName, considerPath))       
        mInfo = mlint( fName, '-id' );        
        for j=1:length(mInfo)  %go through each mlint entry to find wanted ID
            
            if sum(strcmp( mInfo(j).id, IDsToCatch ))>0
                lNrStr = num2str(mInfo(j).line);
                cmdStr = ['<a href="matlab: opentoline(''' fName ''',' lNrStr ',1)">' lNrStr '</a>'];                
                disp([cmdStr ' F: ' fName ' M:' mInfo(j).message ]);
            end
        end
    end
end