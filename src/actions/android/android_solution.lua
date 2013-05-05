
	function premake.android.solution(sln)

		_p('APP_PLATFORM := android-7')
		_p('APP_ABI := armeabi-v7a')
		_p('APP_STL := gnustl_static')

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
