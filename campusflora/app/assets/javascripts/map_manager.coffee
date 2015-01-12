@MapManager = ->
  _map = null

  # Initialize our google maps object and return it
  initialize: ->
    _map = new google.maps.Map $('#map-canvas')[0],
      center:
        lat: -33.886204, 
        lng: 151.189005
      zoom: 19,
      disableDefaultUI: true,
      mapTypeId: google.maps.MapTypeId.SATELLITE

    return _map