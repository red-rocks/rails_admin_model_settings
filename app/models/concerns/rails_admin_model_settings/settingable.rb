module RailsAdminModelSettings
  module Settingable
    extend ActiveSupport::Concern


    included do

      attr_accessor :settings_locked

      embeds_many :settings, class_name: "RailsAdminModelSettings::ObjectSetting", inverse_of: :item, cascade_callbacks: true
      accepts_nested_attributes_for :settings
      history_trackable_options[:except] << :settings if respond_to?(:history_trackable_options) # TODO fix

      def setting(setting_key)
        get_setting_val(setting_key)
      end
      def get_setting(setting_key, options = {}, &block)
        default_creating_options = (new_record? ? {only_init: true} : {overwrite: true})
        get_setting_val(setting_key, options, &block) || get_setting_val(setting_key, options.merge(default_creating_options), &block)
      end
      def get_setting_val(setting_key, options = {}, &block)
        _setting = get_setting_nc(setting_key, options, &block)
        _setting.val unless _setting.nil?
      end
      def get_setting_nc(setting_key, options = {}, &block)
        _settings = if setting_key.is_a?(Hash)
          criteria_hash = setting_key.dup
          options.merge!(setting_key)
          setting_key = setting_key[:key]

          self.settings.where(criteria_hash)
        else
          self.settings.where(key: setting_key)
        end
        ret = _settings.enabled.first
        return ret if !options[:overwrite] and !options[:only_init]

        setting_key = setting_key.to_s
        ::Settings.mutex.synchronize do
          self.settings_locked = true

          _overwrite = options[:overwrite]
          _only_init = options[:only_init]
          if ret.nil? or (_overwrite or _only_init)
            ret ||= self.settings.new
            if block
              begin
                if self.persisted? and !options[:only_init]
                  ret.set(setting_key, block.call(ret), options)
                else
                  ret.init(setting_key, block.call(ret), options)
                end
              rescue Exception => ex
                puts "WTF"
                puts ex.inspect
                if self.persisted? and !options[:only_init]
                  ret.set(setting_key, options[:default], options)
                else
                  ret.init(setting_key, options[:default], options)
                end
              end
            else
              if self.persisted? and !options[:only_init]
                ret.set(setting_key, options[:default], options)
              else
                ret.init(setting_key, options[:default], options)
              end
            end
          end
          self.settings_locked = false
        end
        ret
      end
      def get_settings(settings_ns = 'main')
        _settings = if settings_ns.is_a?(Hash)
          settings.where(settings_ns)
        else
          if settings_ns.nil?
            settings
          else
            settings.where(ns: settings_ns)
          end
        end
        # _settings.enabled.to_a
      end


      cattr_reader :initial_settings
      after_initialize :init_settings
      def init_settings
        (self.class.initial_settings || []).each do |s|
          get_setting_nc(s[:key], s[:opts].merge(only_init: true), &s[:block])
          # current_setting = self.settings.where(key: key).first
          # unless current_setting
          #   self.settings.new(key: key)
          # end
        end

      end

    end


    class_methods do
      def init_setting(key, opts = {}, &block)
        class_variable_set("@@initial_settings", []) unless self.initial_settings
        overwrite = opts.delete(:overwrite)
        initial_settings
        current_setting = initial_settings.detect { |s| s[:key] == key }
        if current_setting
          if overwrite
            current_setting = {
              key: key,
              opts: opts,
              block: block
            }
          end
        else
          initial_settings << {
            key: key,
            opts: opts,
            block: block
          }
        end
        class_variable_set("@@initial_settings", initial_settings)
      end
    end

  end
end