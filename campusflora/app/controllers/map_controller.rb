class MapController < ApplicationController
  def index
    @species = Species.includes(:family).includes(:species_locations).includes(:pictures).uniq(:species).all
    @species = @species.to_json(include: [:species_locations, :family, :pictures => {:methods => :picture_url}])
  end
end
