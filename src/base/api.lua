--
-- api.lua
-- Implementation of the solution, project, and configuration APIs.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--


--
-- Here I define all of the getter/setter functions as metadata. The actual
-- functions are built programmatically below.
--
	
	premake.fields = 
	{
		basedir =
		{
			kind  = "path",
			scope = "container",
		},
		
		buildaction =
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"Compile",
				"Copy",
				"Embed",
				"None"
			}
		},
		
		buildoptions =
		{
			kind  = "list",
			scope = "config",
		},

		configurations = 
		{
			kind  = "list",
			scope = "solution",
		},
		
		defines =
		{
			kind  = "list",
			scope = "config",
		},
		
		excludes =
		{
			kind  = "filelist",
			scope = "container",
		},
		
		files =
		{
			kind  = "filelist",
			scope = "container",
		},
		
		flags =
		{
			kind  = "list",
			scope = "config",
			isflags = true,
			allowed = {
				"ExtraWarnings",
				"FatalWarnings",
				"Managed",
				"NativeWChar",
				"No64BitChecks",
				"NoEditAndContinue",
				"NoExceptions",
				"NoFramePointer",
				"NoImportLib",
				"NoManifest",
				"NoNativeWChar",
				"NoPCH",
				"NoRTTI",
				"Optimize",
				"OptimizeSize",
				"OptimizeSpeed",
				"SEH",
				"StaticRuntime",
				"Symbols",
				"Unicode",
				"WinMain"
			}
		},
		
		implibdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		implibextension =
		{
			kind  = "string",
			scope = "config",
		},
		
		implibname =
		{
			kind  = "string",
			scope = "config",
		},
		
		implibprefix =
		{
			kind  = "string",
			scope = "config",
		},
		
		includedirs =
		{
			kind  = "dirlist",
			scope = "config",
		},
		
		kind =
		{
			kind  = "string",
			scope = "config",
			allowed = {
				"ConsoleApp",
				"WindowedApp",
				"StaticLib",
				"SharedLib"
			}
		},
		
		language =
		{
			kind  = "string",
			scope = "container",
			allowed = {
				"C",
				"C++",
				"C#"
			}
		},
		
		libdirs =
		{
			kind  = "dirlist",
			scope = "config",
		},
		
		linkoptions =
		{
			kind  = "list",
			scope = "config",
		},
		
		links =
		{
			kind  = "list",
			scope = "config",
		},
		
		location =
		{
			kind  = "path",
			scope = "container",
		},
		
		objdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		pchheader =
		{
			kind  = "path",
			scope = "config",
		},
		
		pchsource =
		{
			kind  = "path",
			scope = "config",
		},
		
		prebuildcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		prelinkcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		postbuildcommands =
		{
			kind  = "list",
			scope = "config",
		},
		
		resdefines =
		{
			kind  = "list",
			scope = "config",
		},
		
		resincludedirs =
		{
			kind  = "dirlist",
			scope = "config",
		},
		
		resoptions =
		{
			kind  = "list",
			scope = "config",
		},
		
		targetdir =
		{
			kind  = "path",
			scope = "config",
		},
		
		targetextension =
		{
			kind  = "string",
			scope = "config",
		},
		
		targetname =
		{
			kind  = "string",
			scope = "config",
		},
		
		targetprefix =
		{
			kind  = "string",
			scope = "config",
		},
		
		uuid =
		{
			kind  = "string",
			scope = "container",
			allowed = function(value)
				local ok = true
				if (#value ~= 36) then ok = false end
				for i=1,36 do
					local ch = value:sub(i,i)
					if (not ch:find("[ABCDEFabcdef0123456789-]")) then ok = false end
				end
				if (value:sub(9,9) ~= "-")   then ok = false end
				if (value:sub(14,14) ~= "-") then ok = false end
				if (value:sub(19,19) ~= "-") then ok = false end
				if (value:sub(24,24) ~= "-") then ok = false end
				if (not ok) then
					return nil, "invalid UUID"
				end
				return value
			end
		},
	}


--
-- End of metadata
--
	
	
		
--
-- Check to see if a value exists in a list of values, using a 
-- case-insensitive match. If the value does exist, the canonical
-- version contained in the list is returned, so future tests can
-- use case-sensitive comparisions.
--

	local function checkvalue(value, allowed)
		if (allowed) then
			if (type(allowed) == "function") then
				return allowed(value)
			else
				for _,v in ipairs(allowed) do
					if (value:lower() == v:lower()) then
						return v
					end
				end
				return nil, "invalid value '" .. value .. "'"
			end
		else
			return value
		end
	end



--
-- Retrieve the current object of a particular type from the session. The
-- type may be "solution", "container" (the last activated solution or
-- project), or "config" (the last activated configuration). Returns the
-- requested container, or nil and an error message.
--

	function premake.getobject(t)
		local container
		
		if (t == "container" or t == "solution") then
			container = premake.CurrentContainer
		else
			container = premake.CurrentConfiguration
		end
		
		if (t == "solution" and type(container) ~= "solution") then
			container = nil
		end
		
		local msg
		if (not container) then
			if (t == "container") then
				msg = "no active solution or project"
			elseif (t == "solution") then
				msg = "no active solution"
			else
				msg = "no active solution, project, or configuration"
			end
		end
		
		return container, msg
	end
	
	
	
--
-- Adds values to an array field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setarray(ctype, fieldname, value, allowed)
		local container, err = premake.getobject(ctype)
		if (not container) then
			error(err, 3)
		end

		if (not container[fieldname]) then
			container[fieldname] = { }
		end

		local function doinsert(value, depth)
			if (type(value) == "table") then
				for _,v in ipairs(value) do
					doinsert(v, depth + 1)
				end
			else
				value, err = checkvalue(value, allowed)
				if (not value) then
					error(err, depth)
				end
				table.insert(container[fieldname], value)
			end
		end

		if (value) then
			doinsert(value, 5)
		end
		
		return container[fieldname]
	end

	

--
-- Adds values to an array-of-directories field of a solution/project/configuration. 
-- `ctype` specifies the container type (see premake.getobject) for the field. All
-- values are converted to absolute paths before being stored.
--

	local function domatchedarray(ctype, fieldname, value, matchfunc)
		local result = { }
		
		function makeabsolute(value)
			if (type(value) == "table") then
				for _,item in ipairs(value) do
					makeabsolute(item)
				end
			else
				if value:find("*") then
					makeabsolute(matchfunc(value))
				else
					table.insert(result, path.getabsolute(value))
				end
			end
		end
		
		makeabsolute(value)
		return premake.setarray(ctype, fieldname, result)
	end
	
	function premake.setdirarray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchdirs)
	end
	
	function premake.setfilearray(ctype, fieldname, value)
		return domatchedarray(ctype, fieldname, value, os.matchfiles)
	end
	
	
	
--
-- Set a new value for a string field of a solution/project/configuration. `ctype`
-- specifies the container type (see premake.getobject) for the field.
--

	function premake.setstring(ctype, fieldname, value, allowed)
		-- find the container for this value
		local container, err = premake.getobject(ctype)
		if (not container) then
			error(err, 4)
		end
	
		-- if a value was provided, set it
		if (value) then
			value, err = checkvalue(value, allowed)
			if (not value) then 
				error(err, 4)
			end
			
			container[fieldname] = value
		end
		
		return container[fieldname]	
	end
	
	
	
--
-- The getter/setter implemention.
--

	local function accessor(name, value)
		local kind    = premake.fields[name].kind
		local scope   = premake.fields[name].scope
		local allowed = premake.fields[name].allowed
		
		if (kind == "string") then
			return premake.setstring(scope, name, value, allowed)
		elseif (kind == "path") then
			return premake.setstring(scope, name, path.getabsolute(value))
		elseif (kind == "list") then
			return premake.setarray(scope, name, value, allowed)
		elseif (kind == "dirlist") then
			return premake.setdirarray(scope, name, value)
		elseif (kind == "filelist") then
			return premake.setfilearray(scope, name, value)
		end
	end



--
-- Build all of the getter/setter functions from the metadata above.
--
	
	for name,_ in pairs(premake.fields) do
		_G[name] = function(value)
			return accessor(name, value)
		end
	end
	


--
-- Project object constructors.
--

	function configuration(keywords)
		local container, err = premake.getobject("container")
		if (not container) then
			error(err, 2)
		end
		
		local cfg = { }
		table.insert(container.blocks, cfg)
		premake.CurrentConfiguration = cfg
		
		if (type(keywords) == "table") then
			cfg.keywords = keywords
		else
			cfg.keywords = { keywords }
		end

		-- initialize list-type fields to empty tables
		for name, field in pairs(premake.fields) do
			if (field.kind ~= "string" and field.kind ~= "path") then
				cfg[name] = { }
			end
		end
		
		return cfg
	end
	
		
	function project(name)
		if (name) then
			-- identify the parent solution
			local sln
			if (type(premake.CurrentContainer) == "project") then
				sln = premake.CurrentContainer.solution
			else
				sln = premake.CurrentContainer
			end			
			if (type(sln) ~= "solution") then
				error("no active solution", 2)
			end
			
			-- if this is a new project, create it
			premake.CurrentContainer = sln.projects[name]
			if (not premake.CurrentContainer) then
				local prj = { }
				premake.CurrentContainer = prj

				-- add to master list keyed by both name and index
				table.insert(sln.projects, prj)
				sln.projects[name] = prj
				
				-- attach a type
				setmetatable(prj, {
					__type = "project",
				})
				
				prj.solution       = sln
				prj.name           = name
				prj.basedir        = os.getcwd()
				prj.location       = prj.basedir
				prj.uuid           = os.uuid()
				prj.filter         = { }
				prj.blocks         = { }
			end
		end
	
		if (type(premake.CurrentContainer) == "project") then
			-- add an empty, global configuration to the project
			configuration { }
			return premake.CurrentContainer
		else
			return nil
		end	
	end


	function solution(name)
		if (name) then
			premake.CurrentContainer = _SOLUTIONS[name]
			if (not premake.CurrentContainer) then
				local sln = { }
				premake.CurrentContainer = sln

				-- add to master list keyed by both name and index
				table.insert(_SOLUTIONS, sln)
				_SOLUTIONS[name] = sln
				
				-- attach a type
				setmetatable(sln, { 
					__type="solution"
				})

				sln.name           = name
				sln.location       = os.getcwd()
				sln.projects       = { }
				sln.blocks         = { }
				sln.configurations = { }
			end
		end

		-- make the solution active and return it
		if (type(premake.CurrentContainer) == "project") then
			premake.CurrentContainer = premake.CurrentContainer.solution
		end
		
		if (premake.CurrentContainer) then
			-- add an empty, global configuration
			configuration { }
		end
		
		return premake.CurrentContainer
	end

	