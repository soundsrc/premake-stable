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
			premake.generate(sln, "jni/Android.mk", android.androidmk)
			if not sln.appid then
				error("Please specify an appid. (i.e. appid \"com.company.appid\")")
			end
			if not sln.androidactivity then
				error("Please specify androidactivity. (i.e. androidactivity \"MyActivity\")")
			end
			if not sln.androidtargetid then
				error("Please specify androidtargetid. (i.e. androidtargetid \"android-8\")")
			end
			
			local android_bin = _OPTIONS.android
			if not android_bin then
				android_bin = "android"
			end

			local f = io.open("AndroidManifest.xml","r")
			if f ~= nil then
				io.close(f)
			else
				if 0 ~= os.executeshellf("%s create project -p . -n %s -t %s -k %s -a %s",android_bin,sln.name,sln.androidtargetid,sln.appid,sln.androidactivity) then
					error("Failed to create android project.")
				end
			end
			if 0 ~= os.executeshellf("%s update project -p . -n %s -t %s",android_bin,sln.name,sln.androidtargetid) then
				error("Failed to update android project.")
			end
		end,

		onproject = function(prj)
			premake.generate(prj, "jni/%%.mk", android.project)
		end,

		oncleansolution = function(sln)
			premake.clean.file(sln, "jni/Android.mk")
		end,
		
		oncleanproject  = function(prj)
			premake.clean.file(prj, "jni/%%.mk")
		end,
	}
