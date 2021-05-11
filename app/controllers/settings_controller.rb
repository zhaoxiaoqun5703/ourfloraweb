class SettingsController < InheritedResources::Base

  private

    def settings_params
      params.require(:settings).permit(:about_page_content)
    end
end

