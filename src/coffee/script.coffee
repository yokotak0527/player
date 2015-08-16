$win         = $(window)
$body        = $('body')
resizeEvents = {}

# ==============================================================================
# オブザーバー
# ==============================================================================

setObserver = ($video,video)->
	$win.on({
		'resize' : (()->
			timer    = undefined
			distance = 500
			return (e)->
				if timer then clearTimeout(timer)
				timer = setTimeout(()->
					for key of resizeEvents then resizeEvents[key](e)
					return
				,distance)
				return
		)()
	})

	$video.on({
		'loadeddata' : (e)->
			events = video.getEventsObj('loaded')
			for key of events then events[key](e)
			return
		'ended'      : (e)->
			events = video.getEventsObj('ended')
			for key of events then events[key](e)
			return
		'timeupdate' : (e)->
			events = video.getEventsObj('timeupdate')
			for key of events then events[key](e)
			return
		'play'       : (e)->
			events = video.getEventsObj('play')
			for key of events then events[key](e)
			return
		'pause'      : (e)->
			events = video.getEventsObj('pause')
			for key of events then events[key](e)
			return
		}
	)


# ==============================================================================
# ビデオ
# ==============================================================================
class Video
	_videoInstance = false
	_hasVideo      = false
	_receivesObj   = {}
	_loop          = false
	_speed         = false
	_eventsObj     =
		'loaded'     : {}
		'ended'      : {}
		'timeupdate' : {}
		'play'       : {}
		'pause'      : {}
	# --------------------------------------------------------------------------
	# ビデオURLのセット
	# --------------------------------------------------------------------------
	_receivesObj.urlSet = (blob)->
		@$video.attr('src',window.URL.createObjectURL(blob))
		_hasVideo = true
		return
	# --------------------------------------------------------------------------
	# ビデオの再生
	# --------------------------------------------------------------------------
	_receivesObj.play = (blob)->
		if _hasVideo then @$video[0].play()
		return
	# --------------------------------------------------------------------------
	# シーク操作によって再生時位置が変更された
	# --------------------------------------------------------------------------
	_receivesObj.seekChanged = (val)->
		@$video[0].currentTime = val
		return
	# --------------------------------------------------------------------------
	# 再生速度が変更された
	# --------------------------------------------------------------------------
	_receivesObj.speedChanged = (val)->
		@$video[0].playbackRate = val
		return
	# --------------------------------------------------------------------------
	# ビデオの停止
	# --------------------------------------------------------------------------
	_receivesObj.pause = (blob)->
		if _hasVideo
			$video = @$video
			$video[0].pause()
		return
	# --------------------------------------------------------------------------
	# ビデオのループ設定
	# --------------------------------------------------------------------------
	_receivesObj.loop = (blob)->
		_loop = if _loop == true then false else true
		return
	# --------------------------------------------------------------------------
	# 再生終了後の処理
	# --------------------------------------------------------------------------
	_after = (e)->
		_video = @$video[0]
		if _loop
			_video.currentTime = 0
			_video.play()
		else
			_video.currentTime = 0
		return
	# --------------------------------------------------------------------------
	# ビデオの位置調整
	# --------------------------------------------------------------------------
	_styleFix = (e)->
		_$video     = @$video
		_$videoWrap = @$videoWrap
		_h          = _$video.height()
		_wrap_h     = _$videoWrap.height()
		_$video.css('height','auto')
		if _wrap_h > _h
			_$video.css({
				'margin-top' : ( ( _h + 100 ) / 2 ) * -1
				'top'        : '50%'
			})
		else
			_$video.css({
				'height'     : _wrap_h
				'margin-top' : 0
				'top'        : 0
			})
		return
	# --------------------------------------------------------------------------
	# コンストラクタ
	# --------------------------------------------------------------------------
	constructor : ($video,resizeEvents,$videoWrap)->
		if _videoInstance
			return _videoInstance
		else
			_videoInstance = @
		@$video     = $video
		@$videoWrap = $videoWrap
		_eventsObj.ended.after     = (e)=> _after.call(@,e)
		resizeEvents.videoStyleFix = (e)=> _styleFix.call(@,e)
	# --------------------------------------------------------------------------
	# イベントリスナーの取得
	# --------------------------------------------------------------------------
	getEventsObj : (name)->
		if name == 'all'
			return _eventsObj
		else if name && _eventsObj[name]
			return _eventsObj[name]
		else
			return false
	# --------------------------------------------------------------------------
	# イベントの受け取り
	# --------------------------------------------------------------------------
	receiveEvent : (name,arr)->
		if name == 'upload'       then _receivesObj.urlSet.call(@,arr[0])
		if name == 'play'         then _receivesObj.play.call(@)
		if name == 'pause'        then _receivesObj.pause.call(@)
		if name == 'loop'         then _receivesObj.loop.call(@)
		if name == 'seekChanged'  then _receivesObj.seekChanged.call(@,arr[0])
		if name == 'speedChanged' then _receivesObj.speedChanged.call(@,arr[0])
		return
	# --------------------------------------------------------------------------
	# $オブジェクトを返す
	# --------------------------------------------------------------------------
	get$obj : ()->
		return @$video



# ==============================================================================
# アップローダー
# ==============================================================================
class FileUploader
	_upload = (e)->
		file = e.target.files[0]
		if !/^video/.test(file.type)
			alert "動画形式ではありません。"
			return false
		@video.receiveEvent(
			'upload',
			[new Blob([file],{type:file.type})]
		)
		return

	constructor : (video,$input)->
		@video  = video
		@$input = $input

		@$input.on('change',(e)=> _upload.call(@,e))


# ==============================================================================
# コントローラー : シーク
# ==============================================================================

class Seek
	_time     = 0 # 現在の再生位置
	_duration = 0 # 動画の長さ
	_hasVideo = false
	_isDrag   = false
	# --------------------------------------------------------------------------
	# 経過時間などの取得
	# --------------------------------------------------------------------------
	_setSeekTimes = ()->
		_video    = @video.get$obj()[0]
		_time     = _video.currentTime
		_duration = _video.duration
		return
	# --------------------------------------------------------------------------
	# 表示時間の変更
	# --------------------------------------------------------------------------
	_changeSeekCount = ()->
		_setSeekTimes.call(@)
		@$nowSeek.text(_time+' / '+_duration)
		return
	# --------------------------------------------------------------------------
	# シークバー変更
	# --------------------------------------------------------------------------
	_changeSeekbar = (e)->
		_setSeekTimes.call(@)
		if !_isDrag
			@$seek.val( Math.round( ( _time / _duration ) * 10000 ) / 100 )
		return
	# --------------------------------------------------------------------------
	# シーク初期化
	# --------------------------------------------------------------------------
	_seekInit = (e)->
		_hasVideo = true
		_video    = $(e.target)[0]
		_time     = _video.currentTime
		_duration = _video.duration
		@$seek.val(_time)
		_changeSeekCount.call(@)
		return
	# --------------------------------------------------------------------------
	# シークバー操作後
	# --------------------------------------------------------------------------
	_seekUp = (e)->
		_setSeekTimes.call(@)
		_val = ( @$seek.val() / 100 ) * _duration
		@video.receiveEvent( 'seekChanged',[_val] )
		_isDrag = false
		return
	# --------------------------------------------------------------------------
	# シークバー操作中
	# --------------------------------------------------------------------------
	_seekInput = (e)->
		if !_hasVideo
			e.preventDefault()
			$(e.target).val(0)
		else
			_isDrag = true
		return
	# --------------------------------------------------------------------------
	#
	# --------------------------------------------------------------------------
	constructor : (video,$seek,$nowSeek)->
		@$seek       = $seek
		@$nowSeek    = $nowSeek
		@video       = video
		@videoEvents = @video.getEventsObj('all')
		@$seek.on('input',(e)=> _seekInput.call(@,e) )
		@$seek.on('change',(e)=> _seekUp.call(@,e) )
		@$seek.on('',(e)=> _seekUp.call(@,e) )
		@videoEvents.loaded['seekInit']          = (e)=> _seekInit.call(@,e)
		@videoEvents.timeupdate['changeSeekbar'] = (e)=>
			_changeSeekbar.call(@,e)
			_changeSeekCount.call(@,e)
		return

# ==============================================================================
# コントローラー : ボタン
# ==============================================================================
class ControllerBtns

	_changeBtn = (type)->
		switch type
			when 'play'
				@btns.$play.addClass('active')
				@btns.$pause.removeClass('active')
			when 'pause'
				@btns.$pause.addClass('active')
				@btns.$play.removeClass('active')
		return

	_play = (e)->
		e.preventDefault()
		@video.receiveEvent('play')
		return

	_pause = (e)->
		e.preventDefault()
		@video.receiveEvent('pause')
		return

	_myLoop = (e)->
		e.preventDefault()
		if @btns.$loop.hasClass('active')
			@btns.$loop.removeClass('active')
		else
			@btns.$loop.addClass('active')
		@video.receiveEvent('loop')
		return

	_btnsReset = (e)->
		@btns.$play.removeClass('active')
		@btns.$pause.removeClass('active')
		return

	constructor : (video,btns)->
		@video       = video
		@btns        = btns
		@videoEvents = @video.getEventsObj('all')
		@btns.$play.on('click',(e)=> _play.call(@,e))
		@btns.$pause.on('click',(e)=> _pause.call(@,e))
		@btns.$loop.on('click',(e)=> _myLoop.call(@,e))
		@videoEvents.play['changeBtn']   = (e)=> _changeBtn.call(@,'play')
		@videoEvents.pause['changeBtn']  = (e)=> _changeBtn.call(@,'pause')
		@videoEvents.loaded['btnsReset'] = (e)=> _btnsReset.call(@)

# ==============================================================================
# コントローラー : スピード
# ==============================================================================
class Speed

	_setSpeedMeter = ()->
		@$meter.text(@val)
		return

	_speedChange = (e)->
		@val = @$input.val()
		_setSpeedMeter.call(@)
		@video.receiveEvent('speedChanged',@val)
		return

	_speedReset = (e)->
		@$input.val(@defaultVal)
		@val = @$input.val()
		_setSpeedMeter.call(@)
		_speedChange.call(@)
		return

	constructor : (video,input,meter)->
		@video       = video
		@$input      = $(input)
		@$meter      = $(meter)
		@val         = @$input.val()
		@defaultVal  = @val
		@videoEvents = @video.getEventsObj('all')
		@$input.on('change',(e)=> _speedChange.call(@,e) )
		@videoEvents.loaded['speedReset'] = (e)=> _speedReset.call(@,e)


# ==============================================================================
#
# ==============================================================================

do->
	video          = new Video( $('#video'),resizeEvents,$('#video_wrap') )
	fileUploader   = new FileUploader( video,$('#file') )
	seek           = new Seek( video,$('#seek'),$('#now_seek') )
	speed          = new Speed( video,'#speed','#now_speed' )
	controllerBtns = new ControllerBtns(
		video
		{
			'$play'  : $('#controllers_btn .play a')
			'$pause' : $('#controllers_btn .pause a')
			'$loop'  : $('#controllers_btn .loop a')
		}
	)
	setObserver($('#video'),video)
	$win.trigger('resize')
	return