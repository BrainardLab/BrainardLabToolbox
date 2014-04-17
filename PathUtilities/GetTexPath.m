function texpath = GetTexPath
% texpath = GetTexPath -- Return auto-detected installation path
% for tex utilites, if any. Return empty string if auto-detection not
% possible.%
%
% A typical usage is like this:
%   mytexcommand = [GetTexPath 'pdflatex filename']; system(mytexcommand);
% This runs pdflatex on the named file.  
%
% GetTexPath will return the path to be prefixed in front of the tex
% executable. If none can be found, the tex executable will be executed
% without path spec. If it is installed in the system executable search
% path, it will then still work.
%
% The function simply checks if the tex executable pdflatex is in the Matlab path
% and returns a proper path-spec. If it isn't found in the Matlab path, it
% tries default path locations for OS-X and Windows. If that doesn't work,
% it returns an empty string.  The assumption here is that all the tex
% utililites live in the same directory as pdflatex.
%
% History:
% 07/12/13 Written based on GetSubversionPath (DHB).

% Check for alternative install location of Subversion:
if IsWin
	% Search for Windows executable in Matlabs path:
	texpath = which('pdflatex.exe');
else
	% Search for Unix executable in Matlabs path:
	texpath = which('pdflatex.');
end

% Found one?
if ~isempty(texpath)
	% Extract basepath and use it:
	texpath=[fileparts(texpath) filesep];
else
	% Could not find tex executable in Matlabs path. Check the default
	% install location on OS-X and abort if it isn't there. On M$-Win we
	% simply have to hope that it is in some system dependent search path.

	% Currently, we only know how to check this for Mac OSX.
	if IsOSX
		texpath = '';   
                                		     
		if isempty(texpath) && exist('/usr/texbin', 'file')
			texpath = '/usr/texbin/';
            
		if isempty(texpath) && exist('/usr/bin/pdflatex','file')
			texpath='/usr/bin/';
		end

		if isempty(texpath) && exist('/usr/local/bin/pdflatex','file')
			texpath='/usr/local/bin/';
		end

		if isempty(texpath) && exist('/bin/pdflatex','file')
			texpath='/bin/';
		end

		if isempty(texpath) && exist('/opt/local/bin/pdflatex', 'file')
			texpath = '/opt/local/bin/';
        end  

        end

	end
end

return;
