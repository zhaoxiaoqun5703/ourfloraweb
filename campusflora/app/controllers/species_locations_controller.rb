class SpeciesLocationsController < InheritedResources::Base

  private

    def species_location_params
      params.require(:species_location).permit()
    end
end

