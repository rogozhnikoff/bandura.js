Playlist = require './playlist'

module.exports = React.createClass
  displayName: 'Playlists'
  getInitialState: ->
    visiblePlaylist: undefined

  showPlaylist: (id) ->
    return =>
      @setState
        visiblePlaylistId: id

  render: ->
    self = @
    playlists = _.map(@props.PLCollection?.getAllPlaylists() or [], (pl) =>
      className = 'b-playlists--menu--item '
      className += 'b-playlists--menu--item__active' if @props.PLCollection.getActivePlaylist()?.getId() is pl.getId()
      return `(
        <li onClick = {self.showPlaylist(pl.getId())} className={className} key={pl.getId()}>{pl.getName()}</li>
      )`
    )
    visiblePlaylist =
      if this.props.PLCollection? and this.state.visiblePlaylistId?
        this.props.PLCollection?.getPlaylistById(this.state.visiblePlaylistId)
      else null

    isPlaying = @props.isPlaying is 'isPlaying' and @props.PLCollection.getActivePlaylist().getId() is visiblePlaylist?.getId()
    return `<div style={{display:'none'}} className="b-playlist--title"></div>` unless @props.visible
    return `(
      <div className="b-playlists">
        <ul className="b-playlists--menu">
          {playlists}
        </ul>
        <Playlist playlist={visiblePlaylist} isPlaying={isPlaying}/>
      </div>
    );`