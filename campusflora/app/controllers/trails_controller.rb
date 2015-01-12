class TrailsController < ApplicationController
  before_action :set_trail, only: [:show, :edit, :update, :destroy]

  # GET /trails
  # GET /trails.json
  def index
    @trails = Trail.includes(:species).all
    respond_to do |format|
      format.html {
        not_found
      }
      format.xml { render :xml => @trails }
      format.json {
        render :json => @trails.to_json(include: [:species => {:only => :id}])
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trail
      @trail = Trail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trail_params
      params[:trail]
    end
end
