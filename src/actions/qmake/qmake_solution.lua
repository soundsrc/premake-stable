
function premake.qmake.solution(sln)
	_p(0, 'TEMPLATE = subdirs')
	
	for prj in premake.solution.eachproject(sln) do
		_p(0, 'SUBDIRS += %s', prj.name)
		_p(1, '%s.file += %s.pro', prj.name, prj.name)
		local deps = premake.getdependencies(prj)
		if #deps > 0 then
			for _, depprj in ipairs(deps) do
				_p(1, '%s.depends += %s', prj.name, depprj.name)
			end
		end
	end
	_p(0, '')
end
