
	function premake.android.solution(sln)
		_p('APP_PLATFORM := %s', sln.androidtargetid)
		if sln.androidapplicationoptions then
			for _,v in ipairs(sln.androidapplicationoptions) do
				_p(v)
			end
		end
	end

	function premake.android.androidmk(sln)
		_p('LOCAL_PATH := $(call my-dir)')
		_p('')
		
		_p('ifndef config')
		_p(1, 'config=Release')
		_p('endif')
		_p('')
		
		for prj in premake.solution.eachproject(sln) do
			_p('include $(LOCAL_PATH)/%s.mk', prj.name)
		end
	end
