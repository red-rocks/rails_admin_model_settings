module RailsAdminModelSettings
  class Engine < ::Rails::Engine

    initializer "RailsAdminModelSettings precompile hook", group: :all do |app|
      app.config.assets.precompile += %w(rails_admin/rails_admin_model_settings.js rails_admin/rails_admin_model_settings.css)
    end

    # initializer 'Include RailsAdminModelSettings::RailsAdminSettingsPatch' do |app|
    #   RailsAdminSettings::Setting.send :include, RailsAdminModelSettings::RailsAdminSettingsPatch
    # end

    # initializer 'Include RailsAdminModelSettings::Helper' do |app|
    #   ActionView::Base.send :include, RailsAdminModelSettings::Helper
    # end

  end
end
