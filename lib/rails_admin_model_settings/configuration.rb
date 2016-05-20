module RailsAdminModelSettings
  class Configuration
    def initialize(abstract_model)
      @abstract_model = abstract_model
    end

    def options 
      @options ||= {}
    end

    protected
    def config
      if @abstract_model
        ::RailsAdmin::Config.model(@abstract_model.model).comments || {}
      else
        {}
      end
    end

  end
end
