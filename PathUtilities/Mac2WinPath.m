function winPath = Mac2WinPath(macPath)
% winPath = Mac2WinPath(path)
%
% Description:
%	Converts a path valid for Mac OS X machines to a Windows formatted
%	path.  Conversion only takes place if run on a Windows machine.

if nargin ~= 1
	error('Usage: Mac2WinPath(macPath)');
end

winPath = macPath;

if IsWin
	winPath(macPath == '/') = '\';
end
