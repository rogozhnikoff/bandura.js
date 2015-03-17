{controls,progress, collections, settingsChanges, videos, buttons, soundEvents} = require('./api')
PLCollection = require('../api/PLCollection')
Bandura = require('../api/Bandura')
Utils = require('../utils/utils')

#========frequently changed values============
progressbar = progress.map((smTrack) ->
  {
  position: smTrack.position
  duration: smTrack.duration
  loaded: smTrack.bytesLoaded / smTrack.bytesTotal
  }
)
playerSettings = settingsChanges.scan({},(settings, changes) ->
  if changes.mute? and changes.mute then soundManager.mute() else soundManager.unmute()
  if changes.volume?
    changes.volume = Bandura.valideVolume(changes.volume)
    changes.mute = false
    soundManager.setup({defaultOptions: {volume: changes.volume}})

  return Utils.extendImmutable(settings, changes)
)

playlistsCollection = collections.scan(new PLCollection(), (collection, ev) ->
  return ev.collection if ev.action is 'setNewCollection'
  if ev.playlist?
    return collection[ev.action](ev.playlist)
  else
    return collection[ev.action].apply(collection, ev.arguments)
)

#Changes volume of current track(SM can't change volume on all tracks)
playerSettings.changes().combine(playlistsCollection, (a,b) ->
  {
    settings: a
    collection: b
  }
).onValue((obj) ->
  {settings, collection} = obj
  soundManager.setVolume(collection.getActivePlaylist()?.getActiveTrack()?.id, settings.volume)
)
#=============================================


playerActions = playlistsCollection.sampledBy(controls, (collection, task) ->
  playlist = collection.getActivePlaylist()
  controlsMethods[task.action](playlist, task)
)


soundEvents.onValue (ev) ->
  switch ev
    when 'finish'
      controls.push action: 'nextTrack'

callbacks = buttons.scan([], (buttons, ev) ->
  return buttons.concat ev
).combine(playlistsCollection, (buttons, collection) ->
  buttons
    .map (btn) -> _.extend(btn, callback: -> btn.action(collection.getActivePlaylist()?.getActiveTrack(), collection))
    .sort (a,b) -> a.order > b.order
)

videoSet = videos.flatMapLatest((query) ->
  protocol = window.location.protocol or 'http:'
  url = protocol + "//gdata.youtube.com/feeds/api/videos/-/Music?q=#{query}&hd=true&v=2&alt=jsonc&safeSearch=strict"
  Bacon.fromPromise(
    $.ajax
      url: url
      dataType: "jsonp"
)).map((response) -> response.data.items)

module.exports = {progressbar, playerSettings, playlistsCollection, playerActions, videoSet, callbacks, soundEvents}

controlsMethods =
  stop: (playlist) ->
    soundManager.stop(playlist?.getActiveTrack()?.id)
    Utils.extendImmutable playlist, {playingStatus: 'Stoped'}
  play: (playlist) ->
    soundManager.pauseAll()
    if playlist?.getActiveTrack()
      soundManager.createSound(playlist.getActiveTrack())
      soundManager.play(playlist.getActiveTrack().id)
    Utils.extendImmutable playlist, {playingStatus: 'isPlaying'}

  pause: (playlist) ->
    soundManager.pauseAll()
    Utils.extendImmutable playlist, {playingStatus: 'Paused'}

  nextTrack: (playlist) ->
    nextTrack = playlist.nextTrack()
    @stop(playlist)
    collections.push
      action: 'update'
      playlist: nextTrack
    controls.push action: 'play'
    Utils.extendImmutable nextTrack, {result: 'switched to next track'}

  previousTrack: (playlist) ->
    previousTrack = playlist.previousTrack()
    @stop(playlist)
    collections.push
      action: 'update'
      playlist: previousTrack
    controls.push action: 'play'
    Utils.extendImmutable previousTrack, {result: 'switched to previous track'}

  setPosition: (playlist, task) ->
    track = soundManager.getSoundById(playlist.getActiveTrack().id)
    position = track.duration * task.percent
    track.setPosition(position)

