module RailsAdminModelSettings
  module ModelSettingable
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def rails_admin_model_settings
        RailsAdminSettings::Setting.ns(rails_admin_settings_ns)
      end

      def settings
        Settings.ns(rails_admin_settings_ns)
      end

      def rails_admin_settings_ns
        "rails_admin_model_settings_#{self.name.gsub("::", "").underscore}"
      end


      def model_setting(key, opts = {})
        _define_method = (opts.has_key?(:define_method) ? opts.delete(:define_method) : true)
        if _define_method 
          method_name = (opts.has_key?(:method_name) ? opts.delete(:method_name) : key)
          if method_name and !respond_to?(method_name)
            singleton_class.define_method method_name do
              settings[key].val
            end
          end
        end
        settings.get(key, opts)
      end
    end

  end
  
end
