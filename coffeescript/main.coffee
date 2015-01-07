showOverlay = ->
  $('#overlay-dark,#popover-outer').css('display', 'block')
  setTimeout ->
    $('#overlay-dark,#popover-outer').addClass('selected')
  , 50

hideOverlay = ->
  $('#overlay-dark,#popover-outer').removeClass('selected')
  setTimeout ->
    $('#overlay-dark,#popover-outer').css('display', 'none')
  , 300

$ ->
  map = null
  families = {}
  trails = {}
  markers = []

  initialize = ->
    map = new google.maps.Map($('#map-canvas')[0], {center: {lat: -33.886204, lng: 151.189005}, zoom: 19, disableDefaultUI: true, mapTypeId: google.maps.MapTypeId.SATELLITE})
    openInfoWindow = null

    $.get "json/families.json", (json) ->

      families = jQuery.extend(true, {}, json);

      familiesSorted = []

      _.each json, (family, familyName) ->
        familiesSorted.push familyName
        families[familyName]['markers'] = []

        _.each family, (species, key) ->
          # List the species in the options menu
          $('#menu-content-list').append("<div class=\"list-row\"><div class=\"text\"><div class=\"title\">#{key}</div><div class=\"subtitle\">#{species.commonName}</div></div><img src=\"/assets/images/disclosure-indicator.png\" class=\"disclosure-indicator\"></div>")

          return unless species.mapPin
          _.each species.mapPin.replace(/[\(|\)]/g, '').split('; '), (coords) ->
            # Place the marker on the map
            coordsSplit = coords.split ", "
            infoWindow = new google.maps.InfoWindow(content: species.genusSpecies)

            marker = new google.maps.Marker(
              position: new google.maps.LatLng(coordsSplit[0], coordsSplit[1]);
              map: map
              title: species.genusSpecies
            )

            markers.push {species: species.genusSpecies.toLowerCase(), marker: marker}

            # Save pins for modification later
            families[familyName]['markers'].push marker

            google.maps.event.addListener marker, "click", ->
              openInfoWindow.close() if openInfoWindow
              infoWindow.open map, marker
              openInfoWindow = infoWindow
              return

      familiesSorted.sort()
      _.each familiesSorted, (family) ->
        $('#menu-content-families').append("<div class=\"family-row\"><div class=\"checkbox family selected\"><i class=\"icon-ok\"></i></div><div class='title'>#{family}</div></div>");

      $('#menu-content-families .family-row').on 'click', ->
        family = families[$(this).find('.title').html()]
        if $(this).find('.checkbox').hasClass('selected')
          $(this).find('.checkbox').removeClass('selected');
          _.each family.markers, (marker) ->
            marker.setMap(null)
        else
          $(this).find('.checkbox').addClass('selected');
          _.each family.markers, (marker) ->
            marker.setMap(map)

      $('#family-select-all').on 'click', ->
        $('.checkbox.family').addClass('selected');
        _.each families, (family) ->
          _.each family.markers, (marker) ->
            marker.setMap(map)

      $('#family-unselect-all').on 'click', ->
        $('.checkbox.family').removeClass('selected');
        _.each families, (family) ->
          _.each family.markers, (marker) ->
            marker.setMap(null)

      $('#menu-content-list .list-row').on 'click', ->
        showOverlay()

      $('#overlay-close').on 'click', ->
        hideOverlay()

      $('#popover-inner').on 'click', (e) ->
        e.stopPropagation()
        return false

      $('#popover-outer').on 'click', ->
        hideOverlay()


      $('#tab-button-families').on 'click', ->
        unless $(this).hasClass 'selected'
          $('.tab-button.selected').removeClass('selected')
          $(this).addClass 'selected'
          $('.menu-content-container').animate
            left: 0
          , 200

      $('#tab-button-trails').on 'click', ->
        unless $(this).hasClass 'selected'
          $('.tab-button.selected').removeClass('selected')
          $(this).addClass 'selected'
          $('.menu-content-container').animate
            left: -300
          , 200

      $('#tab-button-list').on 'click', ->
        unless $(this).hasClass 'selected'
          $('.tab-button.selected').removeClass('selected')
          $(this).addClass 'selected'
          $('.menu-content-container').animate
            left: -600
          , 200

    , 'json'

    $.get "json/trails.json", (json) ->
      trails = jQuery.extend(true, {}, json);

      _.each json, (trail, key) ->
        $('#menu-content-trails').append("<div class=\"family-row\"><div class=\"checkbox trail\"><i class=\"icon-ok\"></i></div><div class=\"title\">#{key}</div></div>");
      
      $('#menu-content-trails .family-row').on 'click', ->
        unless $(this).find('.checkbox').hasClass('selected')
          $('#menu-content-trails .family-row .checkbox').removeClass('selected')
          # First remove all markers from the map
          _.each markers, (marker) ->
            marker.marker.setMap(null)

          # Then add markers for this trail
          species = trails[$(this).find('.title').html()].split('; ')
          _.each species, (current) ->
            _.each markers, (marker) ->
              if marker.species is current.toLowerCase()
                  marker.marker.setMap(map)

          $(this).find('.checkbox').addClass('selected')
        else
          # Unselect trail
          $(this).find('.checkbox').removeClass('selected')
          # Re add all map markers
          _.each markers, (marker) ->
            marker.marker.setMap(map)

    , 'json'

  google.maps.event.addDomListener window, "load", initialize

  $('#expand-menu').on 'click', ->
    $('#expand-menu').toggleClass('selected')
    $('#inner-container').toggleClass('menu-visible')

  $('#mapview-satellite').on 'click', ->
    unless $('#mapview-satellite').hasClass('selected')
      map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
      $('#mapview-standard').removeClass('selected');
      $('#mapview-satellite').addClass('selected');

  $('#mapview-standard').on 'click', ->
    unless $('#mapview-standard').hasClass('selected')
      # Cache the zoom to prevent zoomout when changing mapIdType
      zoom = map.getZoom()
      map.setMapTypeId(google.maps.MapTypeId.ROADMAP);
      $('#mapview-satellite').removeClass('selected');
      $('#mapview-standard').addClass('selected');
      map.setZoom(zoom)