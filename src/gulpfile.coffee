'use strict'
gulp       = require 'gulp'
getConfig  = require './gulp-task/config'

# ==============================================================================
# タスク読み込み
# ==============================================================================
require './gulp-task/watch'
require './gulp-task/libfile'

srcPath   = getConfig('srcPath')
buildPath = getConfig('buildPath')