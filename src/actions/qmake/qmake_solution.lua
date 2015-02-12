
function premake.qmake.solution(sln)
	_p(0, 'TEMPLATE = subdirs')
	
	_p(0, 'SUBDIRS += \\')
	for prj in premake.solution.eachproject(sln) do
		_p(1, '%s \\', prj.name)
	end
	_p(0, '')

	for prj in premake.solution.eachproject(sln) do
		_p(0, '%s.file += %s.pro', prj.name, prj.name)
		local deps = premake.getdependencies(prj)
		if #deps > 0 then
			_p(0, '%s.depends += \\', prj.name)
			for _, depprj in ipairs(deps) do
				_p(1, '%s \\', depprj.name)
			end
			_p(0, '')
		end
		_p(0, '')
	end
	_p(0, '')
end
