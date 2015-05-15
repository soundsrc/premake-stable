PREMAKE
A build configuration tool

 Copyright (C) 2002-2013 by Jason Perkins
 Distributed under the terms of the BSD License, see LICENSE.txt

 The Lua language and runtime library is (C) TeCGraf, PUC-Rio.
 See their website at http://www.lua.org/


 See the file BUILD.txt for instructions on building Premake.


 For questions, comments, or more information, visit the project
 website at http://industriousone.com/premake

MODIFICATIONS

 This branch contains a few modifications to premake for personal usage.

 Features:
	- XCode 4 generator targetting iOS
	- Integrates xcodebuildoptions patch (http://sourceforge.net/p/premake/patches/55/)
	- Android NDK generator
	- UnityBuild support
	- Qt qmake (.pro) generator

 Usage:
	For iOS projects:
		premake4 --os=ios xcode4
		
	For Android projects:
		premake4 --os=android android

	For Qt projects:
		premake4 qmake

 Added commands to premake:
		
	assets(filelist):
		Files to add to the project as resources (iOS)
		eg.
		assets {
			"assets/*.png"
		}

	flags:
		"CPP11" - Enable C++11 settings
		"Qt"    - Enable Qt support

	folderrefs(filelist):
		XCode specific. Similar to assets, except link files as folder references (blue folders).

	qtmodules(list):
		Qt modules to include for qmake projects.

	otherfiles(filelist):
		Files to be added to the project but NOT compiled (XCode,MSVC)
		eg.
		otherfiles {
			"README.txt",
			"dont_compile_me.cpp"
		}

	unitybuild(bool):
		Enable unitybuild for the current project.
		Generates a series of files, Project_UnityBuild0.cpp, Project_UnityBuild1.cpp, ...
		which rolls up multiple source files into a single unit for compilation.
		Don't bother to enable this unless you know what you're doing.
		eg.
		unitybuild "true"

	xcodebuildoptions(list):
		Options to insert into the XCode project
		eg.
		xcodebuildoptions {
			"TARGETED_DEVICE_FAMILY = \"1,2\";",
			"IPHONEOS_DEPLOYMENT_TARGET = 3.2;",
			"INFOPLIST_FILE = Info.plist;"
		}
	