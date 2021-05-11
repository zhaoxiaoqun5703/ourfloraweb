class UsersController < InheritedResources::Base

  private

    def settings_params
      params.require(:settings).permit()
    end
end

