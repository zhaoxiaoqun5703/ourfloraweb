class MapController < ApplicationController
  def index
    @families = Family.includes(:species).order(:name).load
    @families = @families.to_json(include: [:species => {:only => :id}])
    
    # Render list of all trails and species and push to the view as JSON so that backbone can use it
    @species = Species.eager_load(:family, :species_locations, :images)

    @trails = Trail.includes(:species).all
    @trails = @trails.to_json(include: [:species => {:only => :id}])
  end
end