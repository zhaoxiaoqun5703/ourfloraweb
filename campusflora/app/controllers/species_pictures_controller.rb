class SpeciesPicturesController < InheritedResources::Base

  private

    def species_picture_params
      params.require(:species_picture).permit()
    end
end

