# Define SpeciesManager in the global window space as window.SpeciesManager
@SpeciesManager = ->
  # Private variables, functions and backbone objects
  _speciesOuterListView = null
  _trailOuterListView = null
  _speciesRaw = null
  _trailsRaw = null
  _map = null
  _families = {}
  _species = {}
  # Store a reference to the currently open google maps pin window
  _openInfoWindow = null

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

    initialize: ->
      self = @
      
      # Don't close the window if the user clicked inside, only if they clicked on the grey part outsdie
      $('#popover-outer').on 'click', '#popover-inner', (e) ->
        e.stopPropagation()
        return false

      $('#popover-outer').on 'click', (e) ->
        self.closeOverlay()

    # Define javascript events for popover
    events:
      'click #overlay-close' : 'closeOverlay'

    # Fade out the overlay and set display to none to prevent event hogging
    closeOverlay: ->
      self = @
      $('#overlay-dark, #popover-outer').removeClass('selected')
      setTimeout ->
        $('#overlay-dark,#popover-outer').css('display', 'none')
        # After we've faded out the popover, remove it from the DOM
        self.remove()
      , 300

    render: ->
      # Render the element from the template and model
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
    initMapComponents: (parentModel) ->
      self = @

      @parentModel = parentModel
      # Define google maps info window (little box that pops up when you click a marker)
      @infoWindow = new google.maps.InfoWindow(content: @parentModel.get('genusSpecies'))

      # Define google maps marker (red balloon over species on map)
      @marker = new google.maps.Marker(
        position: new google.maps.LatLng(@model.get('lat'), @model.get('lon'));
        map: _map
        title: @parentModel.get('genusSpecies')
      )

      # Add click event listener for the map pins
      google.maps.event.addListener @marker, "click", ->
        _openInfoWindow.close() if _openInfoWindow
        self.infoWindow.open _map, self.marker
        _openInfoWindow = self.infoWindow
        return

    # Methods for hiding and showing google maps markers
    hideMarker: ->
      @infoWindow.close()
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
    mapViews: []
    # Define javascript events
    events:
      'click': 'showPopover'

    initialize: ->
      # Set up a new family list view if one doesn't exist, otherwise add markers to the matching one
      familyListView = null 
      if _families[@model.get('family').name]
        familyListView = _families[@model.get('family').name]
      else
        familyListView = new FamilyListView(model: new FamilyModel(@model.get('family')))
      # Add this to the species managed by it's parent family
      familyListView.addSpecies(@)
      # If there are locations defined for these species, set up new species map views
      for location in @model.get('species_locations')
        # Create a new SpeciesMapView with location data
        mapView = new SpeciesMapView(model: new LocationModel(location))
        # Set up google maps components associated with the species map view
        mapView.initMapComponents @model
        # Save the mapview into the array in this model
        @mapViews.push(mapView)

    # When clicked, show the central popover with the corresponding data
    showPopover: ->
      popover = new SpeciesPopoverView({model: @model})
      $('#popover-outer').append(popover.render().el)

    render: ->
      # Add the species to the species list
      @$el.html @template(@model.toJSON())
      # Render the pin on the map
      this
  )

  # View for families in list
  FamilyListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'family-row'
    # Set outer container for these rows to live in
    outerContainer: '#menu-content-families'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#family-row-template').html())
    # Define javascript events
    events:
      'click' : 'toggleFamily'

    # Whether or not this row is selected - (showing family species on the map)
    selected: true
    # Array of all the map markers that should be toggled by this family
    species: []

    initialize: ->
      @render()

    # Hides / displays the species managed by this family on the map
    toggleFamily: ->
      # Remove selected class from the checkbox inside this view
      if @selected then @$el.find('.checkbox').removeClass 'selected' else @$el.find('.checkbox').addClass 'selected'
        
      # Loop through and hide or show the species markers
      for s in @species
        for mapView in s.mapViews
          if @selected then mapView.hideMarker() else mapView.showMarker()

      # Flip the selected bool
      @selected = !@selected

    addSpecies: (species) ->
      @species.push(species)

    render: ->
      # Add the family to the families list
      @$el.html @template(@model.toJSON())
      $(@outerContainer).append @$el
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
      # Render the species view in the outer container
      @$el.append(view.render().el)
      # Add the species view to the outer object for tracking
      _species[model.get('id')] = view
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
        _.each _species, (species) ->
          for mapView in species
            mapView.showMarker()
      else
        # Unselect all other trails
        @$el.parent().find('.family-row .checkbox').removeClass('selected')

        # Loop through and remove all markers from the map
        _.each _species, (species) ->
          for mapView in species
            mapView.hideMarker()

        # Then show all markers that are associated with this trail
        for s in @model.get('species')
          species = _species[s.id]
          for mapView in species
            mapView.showMarker()

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

  # SpeciesManager.initialize() is the only exported member variable, it will initialize the backbone objects, pull data
  # and set up the collection
  initialize: (species, trails, map) ->
    # Cache local variables
    _speciesRaw = species
    _trailsRaw = trails
    _map = map
    # Create a new list view to kick off species and trail management via backbone
    _speciesOuterListView = new SpeciesOuterListView()
    _trailOuterListview = new TrailOuterListView()
