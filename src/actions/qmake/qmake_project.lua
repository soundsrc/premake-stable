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
			_p(0, 'CONFIG += create_prl link_prl')
		end

		if prj.kind == "StaticLib" then
			_p(0, 'CONFIG += staticlib')
		elseif prj.kind == "SharedLib" then
			_p(0, 'CONFIG += dll')
		end

		-- List the build configurations, and the settings for each
		for cfg in premake.eachconfig(prj) do

			if cfg.name:lower() == "debug" then
				_p(0, 'CONFIG(debug) {')
			elseif cfg.name:lower() == "release" then
				_p(0, 'CONFIG(!debug|release) {')
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

			src_files = {}
			objc_src_files = {}
			header_files = {}
			ui_files = {}
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
			end

			if next(ui_files) ~= nil then
				_p(1, 'FORMS += \\', v)
				for _,v in ipairs(ui_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(src_files) ~= nil then
				_p(1, 'SOURCES += \\', v)
				for _,v in ipairs(src_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(objc_src_files) ~= nil then
				_p(1, 'OBJECTIVE_SOURCES += \\', v)
				for _,v in ipairs(src_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			if next(header_files) ~= nil then
				_p(1, 'HEADERS += \\', v)
				for _,v in ipairs(header_files) do
					_p(2, '%s \\', v)
				end
				_p(1, '')
			end

			local lib_deps = {}
			local deps = premake.getdependencies(prj)
			if #deps > 0 then
				for _, depprj in ipairs(deps) do
					table.insert(lib_deps, depprj.name)
				end
			end

			if #lib_deps > 0 then
				for _,v in ipairs(lib_deps) do
					_p(1, 'PRE_TARGETDEPS += $$OUT_PWD/lib' .. v .. '.a')

					_p(1, 'win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/release/ -l' .. v)
					_p(1, 'else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/debug/ -l' .. v)
					_p(1, 'else:unix: LIBS += -L$$OUT_PWD/ -l' .. v)
					--INCLUDEPATH += $$PWD/
					--DEPENDPATH += $$PWD/
				end
			end

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
				--_p(1, 'QMAKE_PRE_LINK += ' .. table.concat(cfg.prebuildcommands,';'))
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
