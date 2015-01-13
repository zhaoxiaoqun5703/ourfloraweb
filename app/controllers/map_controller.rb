class MapController < ApplicationController
  def index
    # Render list of all trails and species and push to the view as JSON so that backbone can use it
    @species = Species.includes(:family).includes(:species_locations).includes(:pictures).uniq(:species).all
    @species = @species.to_json(include: [:species_locations, :family, :pictures => {:methods => :picture_url}])

    @trails = Trail.includes(:species).all
    @trails = @trails.to_json(include: [:species => {:only => :id}])
  end
end
