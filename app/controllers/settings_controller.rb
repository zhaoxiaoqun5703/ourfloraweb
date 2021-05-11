class SettingsController < InheritedResources::Base

  private

    def setting_params
      params.require(:setting).permit(:about_page_content)
    end
end

