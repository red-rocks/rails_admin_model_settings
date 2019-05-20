require 'rails_admin/adapters/mongoid'
module RailsAdmin
  module Adapters
    module Mongoid

      def get(id, embedded_in = nil)
        if embedded_in and model.respond_to?(:find_through)
          return AbstractObject.new(model.find(id, embedded_in))
        end
        AbstractObject.new(model.find(id))
      rescue => e
        raise e if %w(
          Mongoid::Errors::DocumentNotFound
          Mongoid::Errors::InvalidFind
          Moped::Errors::InvalidObjectId
          BSON::InvalidObjectId
        ).exclude?(e.class.to_s)
      end

    end
  end
end