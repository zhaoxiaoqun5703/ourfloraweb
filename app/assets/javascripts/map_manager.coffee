@MapManager = ->
  _map = null
  _geoMarker = null

  # Initialize our google maps object and return it
  initialize: ->
    # Bind events for expanding side menu
    $('#expand-menu').on 'click', ->
      $('#expand-menu').toggleClass('selected')
      $('#inner-container').toggleClass('menu-visible')

    # If we're on mobile, contract the side menu when the user taps the map
    if IS_MOBILE
      $('#map-canvas').on 'click', ->
        $('#expand-menu').removeClass('selected')
        $('#inner-container').removeClass('menu-visible')

    # Bind events for map type selection buttons
    $('#mapview-satellite').on 'click', ->
      unless $('#mapview-satellite').hasClass('selected')
        _map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
        $('#mapview-standard').removeClass('selected');
        $('#mapview-satellite').addClass('selected');

    $('#mapview-standard').on 'click', ->
      unless $('#mapview-standard').hasClass('selected')
        # Cache the zoom to prevent zoomout when changing mapIdType
        zoom = _map.getZoom()
        _map.setMapTypeId(google.maps.MapTypeId.ROADMAP);
        $('#mapview-satellite').removeClass('selected');
        $('#mapview-standard').addClass('selected');
        _map.setZoom(zoom)

    _map = new google.maps.Map $('#map-canvas')[0],
      center:
        lat: -33.886204, 
        lng: 151.189005
      zoom: 19,
      disableDefaultUI: true,
      mapTypeId: google.maps.MapTypeId.SATELLITE

    # Add a current location marker to the map
    _geoMarker = new GeolocationMarker _map

    # Re center the map over the current position on click
    $('#current-location').on 'click', ->
      _map.panTo _geoMarker.getPosition()



    return _map
