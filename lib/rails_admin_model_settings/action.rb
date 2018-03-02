require 'rails_admin/config/actions'
require 'rails_admin/config/model'

module RailsAdmin
  module Config
    module Actions
      class ModelSettings < Base
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          true
        end

        # Is the action on an object scope (Example: /admin/team/1/edit)
        register_instance_option :member? do
          false
        end

        register_instance_option :rails_admin_settings_ns do
          if @abstract_model and @abstract_model.model.respond_to?(:rails_admin_settings_ns)
            @abstract_model.model.rails_admin_settings_ns
          else
            "rails_admin_model_settings"
          end
        end

        register_instance_option :route_fragment do
          'model_settings'
        end

        register_instance_option :controller do
          Proc.new do |klass|
            @config = ::RailsAdminModelSettings::Configuration.new @abstract_model
            if request.get?
              if @abstract_model
                @model = @abstract_model.model
                @settings = @model.respond_to?(:rails_admin_model_settings) ? @model.rails_admin_model_settings.all : RailsAdminSettings::Setting.none
              else
                @settings = RailsAdminSettings::Setting.ns(@action.rails_admin_settings_ns)
              end

              @setting = @settings.where(id: params[:setting_id]) if params[:setting_id].present?

              if request.xhr?
                render action: @action.template_name, layout: false
              else
                render action: @action.template_name
              end

            end
          end
        end

        register_instance_option :link_icon do
          'fa fa-gear'
        end

        register_instance_option :http_methods do
          [:get]
        end
      end
    end
  end
end
