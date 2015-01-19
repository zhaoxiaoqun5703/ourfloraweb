# Define SpeciesManager in the global window space as window.SpeciesManager
@SpeciesManager = ->
  # Private variables, functions and backbone objects
  _speciesOuterListView = null
  _trailOuterListView = null
  _familyOuterListView = null

  _speciesRaw = null
  _trailsRaw = null
  _familiesRaw = null

  _map = null
  # Store a reference to the currently open google maps pin window
  _openInfoBox = null
  # Store all markers for efficiency when hiding everything
  _markers = []

  # Redefine the template interpolation character used by underscore (to @ from %) to prevent conflicts with rails ERB
  _.templateSettings =
    evaluate:    /\<\@(.+?)\@\>/g,
    interpolate: /\<\@=(.+?)\@\>/g,
    escape:      /\<\@-(.+?)\@\>/g


  # VIEWS -------------------------------------------------------------------------------
  # View for selected species shown in the center of the screen
  SpeciesPopoverView = Backbone.View.extend(
    # Id and class name for popover view
    className: 'popover-inner'
    id: 'popover-inner'
    # Select the underscore template to use, found in view/_map.html.erb
    template: _.template($('#popover-template').html())

    events:
      'click .picture': 'fullscreenPicture'

    initialize: ->
      self = @

      # Don't close the window if the user clicked inside, only if they clicked on the grey part outside
      $('#popover-outer').on 'click', '#popover-inner', (e) ->
        e.stopPropagation()
        return false

      $('#popover-outer').on 'click', (e) ->
        self.closeOverlay()

    # Define javascript events for popover
    events:
      'click #overlay-close' : 'closeOverlay'
      'click #highlight-map' : 'showOnMap'

    # Open a picture in a new tab
    fullscreenPicture: (e) ->
      console.log e.target
      # window.open(url,'_blank');

    # Fade out the overlay and set display to none to prevent invisible z index problems
    closeOverlay: ->
      self = @
      $('#overlay-dark, #popover-outer').removeClass('selected')
      setTimeout ->
        $('#overlay-dark,#popover-outer').css('display', 'none')
        # After we've faded out the popover, remove it from the DOM
        self.remove()
      , 300

    # Highlights the popover species on the map
    showOnMap: ->
      # Hide all markers
      for marker in _markers
        marker.setMap(null)

      # Show markers for this species
      @model.trigger('show')
      @model.trigger('fitMapToScreen')
      @closeOverlay()

    render: ->
      # Render the element from the template and model
      console.log @model.attributes
      @$el.html @template(@model.toJSON())
      # Set display to block from none
      $('#overlay-dark,#popover-outer').css('display', 'block')
      # After a delay of 50 ms, add the class to allow the CSS transition to kick in at the next render loop
      setTimeout ->
        $('#overlay-dark,#popover-outer').addClass('selected')
      , 50
      this
  )

  SpeciesMapView = Backbone.View.extend(
    # Cache the parent model so we can access species data in each sub location
    parentModel: null
      
    # Initialize google maps objects and set the parent model
    initMapComponents: (parentModel, listView) ->
      self = @

      @parentModel = parentModel
      # Define google maps info window (little box that pops up when you click a marker)
      infoTemplate = _.template($('#infobox-template').html())

      @infoBox = new InfoBox(
        content: infoTemplate(@parentModel.attributes)
        pixelOffset: new google.maps.Size(-146, -105)
        closeBoxURL: ''
      )

      # Define google maps marker (red balloon over species on map)
      @marker = new google.maps.Marker(
        position: new google.maps.LatLng(@model.get('lat'), @model.get('lon'));
        map: _map
        title: @parentModel.get('genusSpecies')
      )

      _markers.push @marker

      # Add click event listener for the map pins
      google.maps.event.addListener @marker, "click", ->
        _openInfoBox.close() if _openInfoBox
        self.infoBox.open _map, self.marker
        _openInfoBox = self.infoBox
        return
      
      # Bind the click event on the new infobox to show the popover
      google.maps.event.addListener @infoBox, 'domready', ->
        $("#infobox-#{self.parentModel.id}").on 'click', ->
          listView.showPopover()

    # Methods for hiding and showing google maps markers
    hideMarker: ->
      @infoBox.close()
      @marker.setMap(null)

    showMarker: ->
      @marker.setMap(_map)
  )

  # View for species in menu list
  SpeciesListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'list-row'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#list-row-template').html())
    # Store google maps data
    mapViews: null
    # Define javascript events
    events:
      'click': 'showPopover'

    initialize: ->
      # Initialize the array to prevent sharing of data between extended views
      @mapViews = []
      # If there are locations defined for these species, set up new species map views
      for location in @model.get('species_locations')
        # Create a new SpeciesMapView with location data
        mapView = new SpeciesMapView(model: new LocationModel(location))
        # Set up google maps components associated with the species map view
        mapView.initMapComponents @model, @
        # Save the mapview into the array in this model
        @mapViews.push(mapView)

      # Bind the hide and show events for the model to propogate to the views
      @model.on('hide', @hidePins, @)
      @model.on('show', @showPins, @)
      @model.on('fitMapToScreen', @fitMapToScreen, @)

    # When clicked, show the central popover with the corresponding data
    showPopover: ->
      popover = new SpeciesPopoverView({model: @model})
      $('#popover-outer').append(popover.render().el)

    hidePins: ->
      for mapView in @mapViews
        mapView.hideMarker()

    showPins: ->
      for mapView in @mapViews
        mapView.showMarker()

    # Zooms and pans the google map to fit all currently showing markers
    fitMapToScreen: ->
      # Create a new boundary object
      bounds = new google.maps.LatLngBounds();
      # Extend the outside of the boundaries to fit the pins
      for mapView in @mapViews
         bounds.extend mapView.marker.getPosition()
      # Center the map to the geometric center of all markers
      _map.setCenter bounds.getCenter()
      # Fit boundaries
      _map.fitBounds bounds
      # Remove one zoom level to ensure no marker is on the edge.
      _map.setZoom(_map.getZoom()-1); 
      # Set a minimum zoom to prevent excessive zoom in if there's only 1 marker
      if _map.getZoom() > 19 then _map.setZoom 19

    render: ->
      # Add the species to the species list
      @$el.html @template(@model.toJSON())
      # Render the pin on the map
      this
  )

  # The outer backbone view for the species list
  SpeciesOuterListView = Backbone.View.extend(
    el: '#menu-content-list'

    # Define methods to be run at initialization time
    initialize: ->
      # Create a new species collection to hold the data
      @collection = new speciesCollection(_speciesRaw);
      # Whenever a new object is added to the collection, render it's corresponding view
      @collection.bind 'add', @appendItem
      # Call this view's render() function to render all the initial models that might have been added
      @render()

    render: ->
      # For each model in the collection, render and append them to the list view
      _(@collection.models).each (model) ->
        @appendItem model;
      , @

    appendItem: (model) ->
      # Create a new species view based on the model data
      view = new SpeciesListView({model: model})
      # Since we need to group the list by family, check if a family outer grouped element already exists
      $className = "list-family-#{model.get('family').name.replace(' ', '').toLowerCase()}"
      $selector = $(".#{$className}")
      $familyElement = null
      # If there isn't a family subheading, create one and append it to the list box
      if $selector.length > 0
        $familyElement = $selector
      else
        @$el.append("<div class=\"#{$className} list-subheader\">#{model.get('family').name}</div>")
        $selector = $(".#{$className}")

      # Render the species view in the outer container
      @$el.append(view.render().el)
  )

  # View for families in list
  FamilyListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'family-row'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#family-row-template').html())
    # Define javascript events
    events:
      'click' : 'toggleFamily'

    # Whether or not this row is selected - (showing family species on the map)
    selected: true

    initialize: ->
      # Bind listener functions for the parent model
      @model.on('hideAll', @hideAll, @)
      @model.on('showAll', @showAll, @)

    # Called when all families are being hidden - just set selected to false and uncheck checkbox
    hideAll: ->
      @$el.find('.checkbox').removeClass 'selected'
      @selected = false

    # Called when all families are being hidden - just set selected to false and uncheck checkbox
    showAll: ->
      @$el.find('.checkbox').addClass 'selected'
      @selected = true

    # Hides / displays the species managed by this family on the map
    toggleFamily: ->
      # Remove selected class from the checkbox inside this view
      if @selected then @$el.find('.checkbox').removeClass 'selected' else @$el.find('.checkbox').addClass 'selected'
        
      # Loop through and hide or show the species markers
      speciesModels = []
      for speciesObject in @model.get('species')
        found = _speciesOuterListView.collection.where({id: speciesObject.id})
        if found.length > 0
          for speciesModel in found
            speciesModels.push speciesModel

      for speciesModel in speciesModels
        if @selected then speciesModel.trigger('hide') else speciesModel.trigger('show')

      # Flip the selected bool
      @selected = !@selected

    addSpecies: (species) ->
      @species.push(species)

    render: ->
      # Add the family to the families list
      @$el.html @template(@model.toJSON())
      this
  )

  # The outer backbone view for the species list
  FamilyOuterListView = Backbone.View.extend(
    el: '#menu-content-families'

    events:
      'click #family-select-all': 'selectAll'
      'click #family-unselect-all': 'hideAll'

    # Define methods to be run at initialization time
    initialize: ->
      # Create a new species collection to hold the data
      @collection = new familiesCollection(_familiesRaw);
      # Whenever a new object is added to the collection, render it's corresponding view
      @collection.bind 'add', @appendItem
      # Call this view's render() function to render all the initial models that might have been added
      @render()

    render: ->
      # For each model in the collection, render and append them to the list view
      _(@collection.models).each (model) ->
        @appendItem model;
      , @

    appendItem: (model) ->
      # Create a new species view based on the model data
      view = new FamilyListView({model: model})
      # Render the species view in the outer container
      @$el.append(view.render().el)

    selectAll: ->
      # First, show all markers
      for marker in _markers
        marker.setMap(_map)

      # Then, mark all families as selected
      @collection.each (model) ->
        model.trigger('showAll')

    hideAll: ->
      # First, hide all markers
      for marker in _markers
        marker.setMap(null)

      # Then, uncheck all selected families
      @collection.each (model) ->
        console.log model
        model.trigger('hideAll')
  )

  # The view for each row in the trails menu
  TrailListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'trail-row'
    # Set outer container for these rows to live in
    outerContainer: '#menu-content-trails'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#trail-row-template').html())
    # Define javascript events
    events:
      'click' : 'toggleTrail'

    initialize: ->
      @render()

    # Hides / displays the species managed by this family on the map
    toggleTrail: ->
      # If it's already selected, toggle off by removing selected class from the checkbox inside this view
      if @$el.find('.checkbox').hasClass('selected')
        @$el.find('.checkbox').removeClass('selected')
        # Loop through and show all remaining markers
        for marker in _markers
          marker.setMap(_map)
      else
        # Unselect all other trails
        @$el.parent().find('.trail-row .checkbox').removeClass('selected')

        # Loop through and remove all markers from the map
        for marker in _markers
          marker.setMap(null)

        # Then show all markers that are associated with this trail
        speciesModels = []
        for speciesObject in @model.get('species')
          found = _speciesOuterListView.collection.where({id: speciesObject.id})
          if found.length > 0
            for speciesModel in found
              speciesModels.push speciesModel

        for speciesModel in speciesModels
          if @selected then speciesModel.trigger('hide') else speciesModel.trigger('show')

        @$el.find('.checkbox').addClass('selected')

    render: ->
      # Render and return the trail element
      @$el.html @template(@model.toJSON())
      this
  )

  # The outer backbone view for the species list
  TrailOuterListView = Backbone.View.extend(
    el: '#menu-content-trails'

    # Define methods to be run at initialization time
    initialize: ->
      # Create a new species collection to hold the data
      @collection = new trailsCollection(_trailsRaw);
      # Whenever a new object is added to the collection, render it's corresponding view
      @collection.bind 'add', @appendItem
      # Call this view's render() function to render all the initial models that might have been added
      @render()

    render: ->
      # For each model in the collection, render and append them to the list view
      _(@collection.models).each (model) ->
        @appendItem model;
      , @

    appendItem: (model) ->
      # Create a new species view based on the model data
      view = new TrailListView({model: model})
      # Render the species view in the outer container
      @$el.append(view.render().el)
  )

  # MODELS ----------------------------------------------------------------------------------------
  # Model that holds each species
  SpeciesModel = Backbone.Model.extend({})

  # Model that holds a locations for species
  LocationModel = Backbone.Model.extend({})

  # Model that holds family data
  FamilyModel = Backbone.Model.extend({})

  # Model that holds trail data
  TrailModel = Backbone.Model.extend({})


  # COLLECTIONS -----------------------------------------------------------------------------------
  # Collection that holds JSON returned from /species.json
  speciesCollection = Backbone.Collection.extend(
    # Provide a URL to pull JSON data from
    url: '/species.json'
    # Use the species model
    model: SpeciesModel
  )

  # Collection that holds JSON returned from /trails.json
  trailsCollection = Backbone.Collection.extend(
    # Provide a URL to pull JSON data from
    url: '/trails.json'
    # Use the species model
    model: TrailModel
  )

  # Collection that holds families returned from /families.json
  familiesCollection = Backbone.Collection.extend(
    # Provide a URL to pull JSON data from
    url: '/families.json'
    # Use the species model
    model: FamilyModel
  )

  # SpeciesManager.initialize() is the only exported member variable, it will initialize the backbone objects, pull data
  # and set up the collection
  initialize: (species, trails, families, map) ->
    # Cache local variables
    _speciesRaw = species
    _trailsRaw = trails
    _familiesRaw = families
    _map = map
    # Create a new list view to kick off species and trail management via backbone
    _familyOuterListView = new FamilyOuterListView()
    _speciesOuterListView = new SpeciesOuterListView()
    _trailOuterListview = new TrailOuterListView()

    # Bind click events for menu tabs
    $('#tab-button-families').on 'click', ->
      unless $(this).hasClass 'selected'
        $('.tab-button.selected').removeClass('selected')
        $(this).addClass 'selected'
        $('.menu-content-container').animate
          left: 0
        , 200, 'linear'

    $('#tab-button-trails').on 'click', ->
      unless $(this).hasClass 'selected'
        $('.tab-button.selected').removeClass('selected')
        $(this).addClass 'selected'
        $('.menu-content-container').animate
          left: -300
        , 200, 'linear'

    $('#tab-button-list').on 'click', ->
      unless $(this).hasClass 'selected'
        $('.tab-button.selected').removeClass('selected')
        $(this).addClass 'selected'
        $('.menu-content-container').animate
          left: -600
        , 200, 'linear'

    # Fix height of menus
    $('#menu-content-list').height($(window).height() - $('#tab-button-outer').height())
