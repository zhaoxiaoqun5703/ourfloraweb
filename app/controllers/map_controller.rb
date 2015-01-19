class MapController < ApplicationController
  def index
    # Render list of all trails and species and push to the view as JSON so that backbone can use it
    @species = Species.includes(:family).includes(:species_locations).includes(:images).uniq(:species).order('families.name').all
    @species = @species.to_json(include: [:species_locations, :family, :images => {:methods => [:image_url, :image_url_tiny]}])

    @trails = Trail.includes(:species).all
    @trails = @trails.to_json(include: [:species => {:only => :id}])

    @families = Family.includes(:species).order(:name).all
    @families = @families.to_json(include: [:species => {:only => :id}])
  end
end
