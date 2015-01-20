class SpeciesController < ApplicationController
  before_action :set_species, only: [:show, :edit, :update, :destroy]

  # GET /species
  # GET /species.json
  def index
    @species = Species.includes(:family).includes(:species_locations).includes(:images).uniq(:species).order('families.name').all
    respond_to do |format|
      format.html {
        not_found
      }
      format.xml { render :xml => @species }
      format.json {
        render :json => @species.to_json(include: [:species_locations, :family, :images => {:methods => [:image_url, :image_url_tiny, :image_url_small]}])
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_species
      @species = Species.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def species_params
      params(:species).permit(:species_locations_attributes => [:lat, :lon])
    end
end
