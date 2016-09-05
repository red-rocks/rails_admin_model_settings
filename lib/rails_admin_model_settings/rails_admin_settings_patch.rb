# module RailsAdminModelSettings
#   module RailsAdminSettingsPatch
#     extend ActiveSupport::Concern
#
#     included do
#       if RailsAdminModelSettings.mongoid?
#         field :data, type: Hash, default: {}
#       end
#     end
#
#     def enum_collection
#       data[:enum] ? (data[:enum][:collection] || []) : []
#     end
#
#     def enum_multiple
#       data[:enum] and data[:enum][:multiple]
#     end
#
#     def enum_label
#       data[:enum] ? (data[:enum][:label] || "") : ""
#     end
#
#   end
# end
#
#
# ###################################################################
#
# module RailsAdminSettings
#   module_eval <<-EVAL
#     def self.kinds
#       #{RailsAdminSettings.kinds.to_a.to_s} + ['enum']
#     end
#   EVAL
# end
