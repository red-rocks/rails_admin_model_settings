require "rails_admin_model_settings/version"
require "rails_admin_model_settings/engine"
require 'rails_admin_model_settings/configuration'

require 'rails_admin'
require 'rails_admin_settings'

require 'rails_admin_model_settings/action'


module RailsAdminModelSettings
  class << self
    def orm
      if defined?(::Mongoid)
        :mongoid
      else
        :active_record
      end
    end

    def mongoid?
      orm == :mongoid
    end

    def active_record?
      orm == :active_record
    end
  end

end

require 'rails_admin_model_settings/rails_admin_settings_patch'
