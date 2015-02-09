
function premake.qmake.solution(sln)
	_p(0, 'TEMPLATE = subdirs')
	_p(0, 'SUBDIRS += \\')
	for prj in premake.solution.eachproject(sln) do
		_p('%s.pro \\', prj.name)
	end
	_p(0, '')
end
