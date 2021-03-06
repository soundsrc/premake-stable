-- qmake_project.lua
-- Generates .pri projects

	function premake.qmake.project(prj)

		if prj.kind == "WindowedApp" then
			_p(0, 'TEMPLATE = app')
		elseif prj.kind == "ConsoleApp" then
			_p(0, 'TEMPLATE = app')
			_p(0, 'CONFIG += console')
			_p(0, 'CONFIG -= app_bundle')
		elseif prj.kind == "StaticLib" or prj.kind == "SharedLib" then
			_p(0, 'TEMPLATE = lib')
		end
		_p(0, 'CONFIG -= depend_includepath')

		if prj.kind == "StaticLib" then
			_p(0, 'CONFIG += staticlib')
		elseif prj.kind == "SharedLib" then
			_p(0, 'CONFIG += dll')
		end

		_p(0, 'OBJECTS_DIR = $${OUT_PWD}/objs/' .. prj.name)
		_p(0, 'MOC_DIR = $${OUT_PWD}/mocs/' .. prj.name)
		_p(0, 'UI_DIR = $${OUT_PWD}/uis/' .. prj.name)
		_p(0, 'INCLUDEPATH += $${OUT_PWD}/uis/' .. prj.name)

		-- List the build configurations, and the settings for each
		for cfg in premake.eachconfig(prj) do

			if cfg.name:lower() == "debug" then
				_p(0, 'CONFIG(debug, debug|release): {')
			elseif cfg.name:lower() == "release" then
				_p(0, 'else: {')
			else
				
			end

			if cfg.flags.Qt then
				_p(1, 'greaterThan(QT_MAJOR_VERSION, 4): QT += widgets')
			else
				_p(1, 'CONFIG -= qt')
				_p(1, 'QT = ')
				_p('')
			end

			if cfg.flags.CPP11 then
				_p(1, 'CONFIG += c++11')
				_p('')
			end

			_p(1, 'TARGET = %s', cfg.buildtarget.basename)
			_p(1, '')


			if #cfg.qtmodules > 0 then
				_p(1, 'QT += \\', v)
				for _,v in ipairs(cfg.qtmodules) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(cfg.defines) ~= nil then
				_p(1, 'DEFINES += \\', v)
				for _,v in ipairs(cfg.defines) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(cfg.includedirs) ~= nil then
				_p(1, 'INCLUDEPATH += \\', v)
				for _,v in ipairs(cfg.includedirs) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if cfg.name:lower() == "debug" then
				_p(1, 'win32: LIBS += -L$$OUT_PWD/debug')
			else
				_p(1, 'win32: LIBS += -L$$OUT_PWD/release')
			end
			_p(1, 'else:unix: LIBS += -L$$OUT_PWD')

			if next(cfg.libdirs) ~= nil then
				_p(1, 'LIBS += \\', v)
				for _,v in ipairs(cfg.libdirs) do
					if string.sub(v, 0, 1) == '/' then
						_p(2, '-L%s \\', v)
					else
						_p(2, '-L$${PWD}/%s \\', v)
					end
				end
				_p(1, '')
			end

			src_files = {}
			objc_src_files = {}
			header_files = {}
			ui_files = {}
			rc_files = {}

			for _,v in ipairs(cfg.files) do
				ext = path.getextension(v):lower()
				if path.iscppfile(v) then
					if ext == '.m' or ext == '.mm' then
						table.insert(objc_src_files, v)
					else
						table.insert(src_files, v)
					end
				end
				if path.iscppheader(v) then
					table.insert(header_files, v)
				end

				if ext == '.ui' then
					table.insert(ui_files, v)
				end

				if ext == '.qrc' then
					table.insert(rc_files, v)
				end
			end

			if next(ui_files) ~= nil then
				_p(1, 'FORMS += \\')
				for _,v in ipairs(ui_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(src_files) ~= nil then
				_p(1, 'SOURCES += \\')
				for _,v in ipairs(src_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(objc_src_files) ~= nil then
				_p(1, 'OBJECTIVE_SOURCES += \\')
				for _,v in ipairs(objc_src_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(header_files) ~= nil then
				_p(1, 'HEADERS += \\')
				for _,v in ipairs(header_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(rc_files) ~= nil then
				_p(1, 'RESOURCES += \\')
				for _,v in ipairs(rc_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			local lib_deps = {}
			local deps = premake.getdependencies(prj)
			if #deps > 0 then

				_p(1, 'PRE_TARGETDEPS += \\')
				for _, depprj in ipairs(deps) do
					table.insert(lib_deps, depprj.name)

					target = premake.gettarget(depprj, "link", "posix", "posix", os.get())
					_p(2, '%s \\', target.fullpath)
				end
				_p(1, '')
			end

			if #lib_deps > 0 then
				for _,v in ipairs(lib_deps) do
					_p(1, 'LIBS += -l' .. v)
				end
			end
			_p(0, '')

			-- system libs
			local links = premake.getlinks(cfg, "system", "name")
			if #links > 0 then
				for _,v in ipairs(links) do
					ext = path.getextension(v)
					if ext == '.framework' then
						_p(1, 'LIBS += -framework ' .. path.getbasename(v))
					else
						_p(1, 'LIBS += -l' .. path.getbasename(v))
					end
				end
			end

			if #cfg.prebuildcommands > 0 then
				_p(1, 'prebuild.target = prebuild.tmp')
				_p(1, 'prebuild.commands = ' .. table.concat(cfg.prebuildcommands,';'))
				_p(1, 'QMAKE_EXTRA_TARGETS += prebuild')
				_p(1, 'PRE_TARGETDEPS += prebuild.tmp')
			end

			if #cfg.prelinkcommands > 0 then
				_p(1, 'QMAKE_PRE_LINK += ' .. table.concat(cfg.prelinkcommands,';'))
			end

			if #cfg.postbuildcommands > 0 then
				_p(1, 'QMAKE_POST_LINK += ' .. table.concat(cfg.postbuildcommands,';'))
			end

			_p(0, '}')
		end
	end
