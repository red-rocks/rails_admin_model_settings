module RailsAdminModelSettings
  module ModelSettingable
    extend ActiveSupport::Concern

    module ClassMethods
      def rails_admin_model_settings
        RailsAdminSettings::Setting.ns(rails_admin_settings_ns)
      end

      def settings
        Settings.ns(rails_admin_settings_ns)
      end

      def rails_admin_settings_ns
        "rails_admin_model_settings_#{self.name.gsub("::", "").underscore}"
      end
    end

  end
end
