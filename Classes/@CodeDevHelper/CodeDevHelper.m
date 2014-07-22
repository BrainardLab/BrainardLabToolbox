classdef CodeDevHelper
%
%   @mainpage
%
%   @b Description:
%   The CodeDevHelper class is a utility class which contain
%   static methods only. These methods are useful while developing or
%   debuging a new class. Because all methods are static, theu can be called 
%   from anywhere without having to first instantiate a CodeDevHelper object. 
%
%   History:
%   @code
%   4/18/2013   npc    Wrote it.
%   @endcode
%
	methods (Static = true)
        DisplayModalMessageBox(message, windowTitle);        
        DisplayHierarchicalViewOfObjectProperties(objectVar, objectName);
    end
    
end  % classdef

