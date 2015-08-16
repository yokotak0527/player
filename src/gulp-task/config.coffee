path  = require 'path'
_conf = {}
# ==============================================================================
# 一般
# ==============================================================================
# ビルドディレクトリ名
buildPathName = 'build'
# ソースディレクトリ名
srcPathName   = 'src'
# gulp実行位置(ビルド、ソース両方を包括するディレクトリ)
rootPath      = path.join(process.cwd(),'../')
buildRootPath = path.join(rootPath,buildPathName,'/')
srcRootPath   = path.join(rootPath,srcPathName,'/')

# ==============================================================================
# 利用フラグ
# ==============================================================================
# 画像を圧縮するimgMinを利用するには
# gulp-imagemin
# imagemin-pngquant
# をインストールしてください。
#
_conf.useFlg =
	'coffee' : true
	'sass'   : true
	'imgMin' : false

# ==============================================================================
# パス
# ==============================================================================
# 開発
# ------------------------------------------------------------------------------
# 絶対パス
_conf.srcPath =
	'sass'   : srcRootPath + 'sass/'
	'scss'   : srcRootPath + 'sass/'
	'coffee' : srcRootPath + 'coffee/'
	'cache'  : srcRootPath + '.cache/'
# 相対パス
_conf.relativeSrcPath =
	'sass'   : path.relative(srcRootPath,srcRootPath + 'sass/')
	'scss'   : path.relative(srcRootPath,srcRootPath + 'sass/')
	'coffee' : path.relative(srcRootPath,srcRootPath + 'coffee/')
	'cache'  : path.relative(srcRootPath,srcRootPath + '.cache/')
# ------------------------------------------------------------------------------
# 出力
# ------------------------------------------------------------------------------
# 絶対パス
_conf.buildPath =
	'css'  : buildRootPath + 'css/'
	'img'  : buildRootPath + 'img/'
	'font' : buildRootPath + 'font/'
	'js'   : buildRootPath + 'js/'
# 相対パス
_conf.relativeBuildPath =
	'css'  : path.relative(srcRootPath,buildRootPath + 'css/')
	'img'  : path.relative(srcRootPath,buildRootPath + 'img/')
	'font' : path.relative(srcRootPath,buildRootPath + 'font/')
	'js'   : path.relative(srcRootPath,buildRootPath + 'js/')

# ==============================================================================
# 設定
# ==============================================================================
# Compass
# ------------------------------------------------------------------------------
usrCompassConf    = require(srcRootPath + 'usr/compass.coffee')
_conf.compassConf =
	style       : 'expanded'
	relative    : true
	css         : _conf.relativeBuildPath.css
	image       : _conf.relativeBuildPath.img
	javascript  : _conf.relativeBuildPath.js
	font        : _conf.relativeBuildPath.font
	logging     : true
	require     : []
	import_path : usrCompassConf.import_path
	# 'sass'  : '', # sassは_buildで指定
# ------------------------------------------------------------------------------
# Pleeease
# ------------------------------------------------------------------------------
_conf.pleeeaseConf =
	autoprefixer   : { browsers : ['last 2 version'], cascade: true }
	filters        : { oldIE    : true }
	rem            : true
	opacity        : true
	pseudoElements : true
	mqpacker       : true
	colors         :
		color         : true
		hexAlpha      : true
		hwb           : true
		rebbecapurple : true
# ------------------------------------------------------------------------------
# CoffeeScript
# ------------------------------------------------------------------------------
_conf.coffeeConf =
	bare : false
# ------------------------------------------------------------------------------
# notify
# ------------------------------------------------------------------------------
_conf.notifyConf =
	sound : 'Glass'
# ------------------------------------------------------------------------------
# uglify
# ------------------------------------------------------------------------------
_conf.uglifyConf =
	mangle : true
# ------------------------------------------------------------------------------
# libConf 読み込むライブラリを増やしたい場合はここに追記
# ------------------------------------------------------------------------------
libs = []
libs[0] =
	bundle   : 'common_libs.js'
	destDir  : buildRootPath + 'js/lib/'
	path     :
		'jquery' : srcRootPath + 'bower_components/jQuery/dist/jquery.js'
_conf.libConf =
	libs : libs

# ==============================================================================
# モジュール登録
# ==============================================================================
module.exports = (type)->
	if _conf[type] is undefined
		console.log 'Warning : _conf.'+type+' was called for config.cofee. but, _conf.'+type+' is don\'t exist.'
	else
		return _conf[type]
	return