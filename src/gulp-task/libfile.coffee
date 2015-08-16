gulp              = require 'gulp'
getConfig         = require './config'
concat            = require 'gulp-concat'
uglify            = require 'gulp-uglify'

srcPath           = getConfig 'srcPath'
relativeSrcPath   = getConfig 'relativeSrcPath'
buildPath         = getConfig 'buildPath'
relativeBuildPath = getConfig 'relativeBuildPath'
useFlg            = getConfig 'useFlg'
libConf           = getConfig 'libConf'
libs              = libConf.libs

# ==============================================================================
# 監視タスク登録
# ==============================================================================
gulp.task 'getlibfile',->
	for lib in libs
		libArr = []
		for key,val of lib.path
			libArr.push val
		gulp
			.src(libArr)
			.pipe(concat(lib.bundle))
			.pipe(uglify({preserveComments:'some'}))
			.pipe(gulp.dest(lib.destDir))
	return