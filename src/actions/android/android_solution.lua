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
