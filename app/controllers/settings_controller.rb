class SettingsController < InheritedResources::Base

  private

    def settings_params
      params.require(:settings).permit()
    end
end

