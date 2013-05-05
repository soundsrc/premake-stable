-- android_project.lua
-- Generates Android.mk files in the jni directory

	function premake.android.project(prj)

		_p('ifndef LOCAL_PATH')
		_p('LOCAL_PATH := $(call my-dir)')
		_p('endif')
		_p('')

		_p('include $(CLEAR_VARS)')
		_p('')

		-- List the build configurations, and the settings for each
		for cfg in premake.eachconfig(prj) do
			_p(0, 'ifeq ($(config),%s)', cfg.name)
			_p('')

			_p(1, 'LOCAL_MODULE := %s', cfg.buildtarget.basename)
			if prj.kind == "StaticLib" or prj.kind == "SharedLib" then
				_p(1, 'LOCAL_MODULE_FILENAME := %s%s%s', cfg.buildtarget.prefix, cfg.buildtarget.basename, cfg.buildtarget.suffix)
			else
				_p(1, 'LOCAL_MODULE_FILENAME := %s', cfg.buildtarget.basename)
			end
			_p('')

			export_cflags = ""
			for _,v in ipairs(cfg.defines) do
				export_cflags = export_cflags .. " -D" .. v
			end
			export_cflags = export_cflags .. ' ' .. table.concat(cfg.buildoptions, " ")
			_p(1, "LOCAL_CFLAGS := %s", export_cflags)
			_p('')
			
			_p(1, "LOCAL_C_INCLUDES := \\\n\t\t%s", table.concat(cfg.includedirs, " \\\n\t\t"))
			_p('')
			
			src_files = ""
			for _,v in ipairs(cfg.files) do
				ext = string.lower(path.getextension(v))
				if ext == ".c" or ext == ".cpp" then
					src_files = src_files .. " \\\n\t\t../" .. v
				end
			end
			_p(1, "LOCAL_SRC_FILES := %s", src_files)
			_p('')

			--_p(1, 'Library paths: %s', table.concat(cfg.libdirs, ";"))

			local static_lib_deps = {}
			local shared_lib_deps = {}
			local deps = premake.getdependencies(prj)
			if #deps > 0 then
				for _, depprj in ipairs(deps) do
					if depprj.kind == "StaticLib" then
						table.insert(static_lib_deps, depprj.name)
					elseif depprj.kind == "SharedLib" then
						table.insert(shared_lib_deps, depprj.name)
					end
				end
			end
			
			if #static_lib_deps > 0 then
				_p(1, 'LOCAL_STATIC_LIBRARIES := \\\n\t\t%s', table.concat(static_lib_deps, " \\\n\t\t"))
				_p('')
			end
			
			if #shared_lib_deps > 0 then
				_p(1, 'LOCAL_SHARED_LIBRARIES := \\\n\t\t%s', table.concat(shared_lib_deps, " \\\n\t\t"))
				_p('')
			end

			local links = premake.getlinks(cfg, "system", "basename")
			if #links > 0 then
				_p(1, 'LOCAL_LDLIBS := \\\n\t\t-l%s', table.concat(links, " \\\n\t\t-l"))
			end
			_p('')

			if #cfg.prebuildcommands > 0 then
			end

			if #cfg.prelinkcommands > 0 then
			end

			if #cfg.postbuildcommands > 0 then
			end

			_p(0, 'endif # end %s', cfg.name)
			_p('')
		end

		if prj.kind == "StaticLib" then
			_p('include $(BUILD_STATIC_LIBRARY)')
		else
			_p('include $(BUILD_SHARED_LIBRARY)')
		end
		
	end
