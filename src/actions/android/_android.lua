-- _android.lua
-- Android actions

	premake.android = { }
	local android = premake.android

	
-- The description of the action. Note that only the first three fields are required;
-- you can remove any of the additional fields that are not required by your action.

	newaction 
	{
		trigger = "android",
		
		shortname = "Android",
		
		description = "Android NDK project files",

		valid_kinds = { "WindowedApp", "ConsoleApp", "SharedLib", "StaticLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "gcc" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, "jni/Application.mk", android.solution)
			premake.generate(sln, "jni/Android.mk", android.androidmk)
		end,

		onproject = function(prj)
			premake.generate(prj, "jni/%%.mk", android.project)
		end,

		oncleansolution = function(sln)
			premake.clean.file(sln, "jni/Application.mk")
		end,
		
		oncleanproject  = function(prj)
			premake.clean.file(prj, "jni/%%.mk")
		end,
	}
