-- _qmake.lua
-- qmake project actions

	premake.qmake = { }
	local qmake = premake.qmake

	
-- The description of the action. Note that only the first three fields are required;
-- you can remove any of the additional fields that are not required by your action.

	newaction 
	{
		trigger = "qmake",
		
		shortname = "QMake",
		
		description = "Generate Qt qmake (.pro) project files",

		valid_kinds = { "WindowedApp", "ConsoleApp", "SharedLib", "StaticLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "gcc" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, "%%.pro", qmake.solution)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.pro", qmake.project)
		end,

		oncleansolution = function(sln)
			premake.clean.file(sln, "%%.pro")
		end,
		
		oncleanproject  = function(prj)
			premake.clean.file(prj, "%%.pro")
		end,
	}
