Playlist = require '../api/Playlist'
tracks = require './tracks'

module.exports = [
  new Playlist(tracks.slice(0,3),'Fixture playlist')
  new Playlist(tracks.slice(3,5), 'Second playlist')
  new Playlist(tracks.slice(5), 'Third playlist')
]