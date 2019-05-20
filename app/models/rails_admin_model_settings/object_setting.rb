class RailsAdminModelSettings::ObjectSetting < ::RailsAdminSettings::Setting

  # include NoHistoryTracking
  embedded_in :item, polymorphic: true, inverse_of: :settings, touch: true


  include Hancock::RailsAdminSettingsPatch
  include Hancock::Cache::RailsAdminSettingsPatch if defined?(Hancock::Cache)

  include Hancock::EmbeddedFindable
  # stolen from https://github.com/mongoid/mongoid-history/blob/master/lib/mongoid/history/trackable.rb#L171
  def embed_method_for_parent
    ret = nil
    if self._parent
      ret = self._parent.relations.values.find do |relation|
        if ::Mongoid::Compatibility::Version.mongoid3?
          relation.class_name == self.metadata.class_name.to_s && relation.name == self.metadata.name
        else
          relation.class_name == self.relation_metadata.class_name.to_s &&
          relation.name == self.relation_metadata.name
        end
      end
    end
    (ret and ret.name)
  end

  def self.find(id, embedded_in = nil)
    embedded_in = embedded_in.split('~').map(&:camelize).join('::').constantize if embedded_in and !embedded_in.is_a?(Class)
    find_through(embedded_in, 'settings', id) if embedded_in
  end

  def init(key, value = nil, options = {})
    return self if persisted?
    key = key.to_s
    options.symbolize_keys!

    if !options[:type].nil? && options[:type] == 'yaml' && !value.nil?
      if value.class.name != 'String'
        value = value.to_yaml
      end
    end

    options.merge!(value: value)

    ## from write_to_database
    options[:kind] = options[:kind].to_s if options[:kind]
    is_file = !options[:kind].nil? && (options[:kind] == 'image' || options[:kind] == 'file')
    is_array = !options[:kind].nil? && (options[:kind] == 'array' || options[:kind] == 'multiple_enum' || options[:kind] == 'multiple_custom_enum')
    is_hash = !options[:kind].nil? && (options[:kind] == 'hash')
    if is_file
      options[:raw] = ''
      file = options[:value]
    elsif is_array
      options[:raw] = ''
      options[:raw_array] = options[:value] if options[:value]
    elsif is_hash
      options[:raw] = ''
      options[:raw_hash] = options[:value] if options[:value]
    else
      options[:raw] = options[:value] if options[:value]
    end

    options.delete(:value)
    options.delete(:default)
    options[:ns] ||= "main"
    options[:key] ||= key
    unless self.new_record?
      if options.delete(:overwrite)
        opts = options.dup
        self.assign_attributes(opts)
      end
      self
    else
      opts = options.dup
      if options[:overwrite] == false && !self.value.blank?
        opts.delete(:raw)
        opts.delete(:raw_array)
        opts.delete(:raw_hash)
        opts.delete(:value)
        opts.delete(:enabled)
      end
      opts.delete(:overwrite)
      opts.delete(:only_init)
      self.assign_attributes(opts)
    end
    if is_file and options[:loadable]
      if options[:overwrite] != false || !self.file?
        self.file = file
        # self.save!
      end
    end
    self

  end


  def set(key, value = nil, options = {})
    # load! unless @locked || true if options[:loadable]
    key = key.to_s
    options.symbolize_keys!
    # if options.key?(:cache)
    #   _cache = options.delete(:cache)
    # else
    #   _cache = (name != ::Settings.ns_default)
    # end

    if !options[:type].nil? && options[:type] == 'yaml' && !value.nil?
      if value.class.name != 'String'
        value = value.to_yaml
      end
    end

    # unless options[:cache_keys_str].present?
    #   _cache_keys = options.delete(:cache_keys)
    #   _cache_keys ||= options.delete(:cache_key)
    #
    #   if _cache_keys.nil?
    #     # if _cache
    #     #   options[:cache_keys_str] = name.underscore
    #     # end
    #   else
    #     if _cache_keys.is_a?(::Array)
    #       options[:cache_keys_str] = _cache_keys.map { |k| k.to_s.strip }.join(" ")
    #     else
    #       options[:cache_keys_str] = _cache_keys.to_s.strip
    #     end
    #   end
    # end
    # options.delete(:cache_keys)
    # options.delete(:cache_key)

    options.merge!(value: value)
    if self.item and self.item.settings_locked
      ret = write_to_database(key, options)
    else
      ::Settings.mutex.synchronize do
        ret = write_to_database(key, options)
      end
    end
    ret
  end


  def write_to_database(key, options)

    options[:kind] = options[:kind].to_s if options[:kind]
    is_file = !options[:kind].nil? && (options[:kind] == 'image' || options[:kind] == 'file')
    is_array = !options[:kind].nil? && (options[:kind] == 'array' || options[:kind] == 'multiple_enum' || options[:kind] == 'multiple_custom_enum')
    is_hash = !options[:kind].nil? && (options[:kind] == 'hash')
    if is_file
      options[:raw] = ''
      file = options[:value]
    elsif is_array
      options[:raw] = ''
      options[:raw_array] = options[:value] if options[:value]
    elsif is_hash
      options[:raw] = ''
      options[:raw_hash] = options[:value] if options[:value]
    else
      options[:raw] = options[:value] if options[:value]
    end

    options.delete(:value)
    options.delete(:default)
    options[:ns] ||= "main"
    options[:key] ||= key
    unless self.new_record?
      if options.delete(:overwrite)
        opts = options.dup
        self.update_attributes!(opts)
      end
      self
    else
      opts = options.dup
      if options[:overwrite] == false && !self.value.blank?
        opts.delete(:raw)
        opts.delete(:raw_array)
        opts.delete(:raw_hash)
        opts.delete(:value)
        opts.delete(:enabled)
      end
      opts.delete(:overwrite)
      opts.delete(:only_init)
      self.update_attributes!(opts)
    end
    if is_file and options[:loadable]
      if options[:overwrite] != false || !self.file?
        self.file = file
        self.save!
      end
    end
    self
  end




  rails_admin do
    # navigation_label I18n.t('admin.settings.label')

    list do
      field :label do
        visible false
        # searchable true
        weight 1
      end
      field :enabled, :toggle do
        weight 2
      end
      field :loadable, :toggle do
        # weight 3
        visible false
      end
      field :ns do
        # searchable true
        weight 4
      end
      field :key do
        # searchable true
        weight 5
      end
      field :name do
        weight 6
      end
      field :kind do
        # searchable true
        weight 7
      end
      field :raw_data do
        weight 8
        # pretty_value do
        #   if bindings[:object].file_kind?
        #     "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
        #   elsif bindings[:object].image_kind?
        #     "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
        #   elsif bindings[:object].array_kind?
        #     (bindings[:object].raw_array || []).join("<br>").html_safe
        #   elsif bindings[:object].hash_kind?
        #     "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
        #   else
        #     value
        #   end
        # end
      end
      field :raw do
        weight 8
        # searchable true
        # visible false
        # pretty_value do
        #   if bindings[:object].file_kind?
        #     "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
        #   elsif bindings[:object].image_kind?
        #     "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
        #   else
        #     value
        #   end
        # end
      end
      field :raw_array do
        weight 9
        # searchable true
        # visible false
        # pretty_value do
        #   (bindings[:object].raw_array || []).join("<br>").html_safe
        # end
      end
      field :raw_hash do
        weight 10
        # searchable true
        # visible false
        # pretty_value do
        #   "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
        # end
      end
      field :cache_keys_str, :text do
        weight 11
        # searchable true
        visible false
      end
      # if ::Settings.table_exists?
      #   nss = ::RailsAdminSettings::Setting.pluck(:ns).map { |c|
      #     next if c =~ /^rails_admin_model_settings_/ and defined?(RailsAdminModelSettings)
      #     "ns_#{c.gsub('-', '_')}".to_sym
      #   }.compact
      # else
      #   nss = []
      # end
      # if defined?(RailsAdminModelSettings)
      #   scopes([:no_model_settings, :model_settings, nil] + nss)
      # else
      #   scopes([nil] + nss)
      # end
      scopes([nil])
    end

    edit do
      field :enabled, :toggle do
        weight 1
        visible do
          if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) and bindings[:object].for_admin?
            is_current_user_admin
          else
            true
          end
        end
      end
      field :loadable, :toggle do
        weight 2
        visible do
          false #is_current_user_admin
        end
      end
      field :for_admin, :toggle do
        weight 3
        visible do
          is_current_user_admin
        end
      end
      field :ns  do
        weight 4
        read_only true
        help false
        visible do
          is_current_user_admin
        end
      end
      field :key  do
        weight 5
        read_only true
        help false
        visible do
          is_current_user_admin
        end
      end
      field :label, :string do
        weight 6
        read_only do
          !is_current_user_admin
        end
        help false
      end
      field :kind, :enum do
        weight 7
        read_only do
          !is_current_user_admin
        end
        enum do
          RailsAdminSettings.kinds
        end
        partial "enum_for_settings_kinds".freeze
        help false
      end
      field :raw do
        weight 8
        partial "setting_value".freeze
        # visible do
        #   !bindings[:object].upload_kind? and !bindings[:object].array_kind? and !bindings[:object].hash_kind?
        # end

        visible do
          if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting)
            !bindings[:object].upload_kind? and !bindings[:object].array_kind? and !bindings[:object].hash_kind?
          else
            true
          end
        end
        read_only do
          if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) and bindings[:object].for_admin?
            !is_current_user_admin
          else
            false
          end
        end
      end
      field :raw_array do
        weight 9
        partial "setting_value".freeze
        formatted_value do
          (bindings[:object].raw_array || [])
        end
        pretty_value do
          formatted_value.map(&:to_s).join("<br>").html_safe
        end
        visible do
          bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) ? bindings[:object].array_kind? : true
        end
        read_only do
          if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) and bindings[:object].for_admin?
            !is_current_user_admin
          else
            false
          end
        end
      end
      field :raw_hash do
        weight 10
        partial "setting_value".freeze
        formatted_value do
          (bindings[:object].raw_hash || {})
        end
        pretty_value do
          "<pre>#{JSON.pretty_generate(formatted_value)}</pre>".html_safe
        end
        visible do
          bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) ? bindings[:object].hash_kind? : true
        end
        read_only do
          if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) and bindings[:object].for_admin?
            !is_current_user_admin
          else
            false
          end
        end
      end
      if ::Settings.file_uploads_supported
        field :file, ::Settings.file_uploads_engine do
          weight 11
          visible do
            bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) ? bindings[:object].upload_kind? : true
          end
          read_only do
            if bindings[:object] and bindings[:object].is_a?(RailsAdminModelSettings::ObjectSetting) and bindings[:object].for_admin?
              !is_current_user_admin
            else
              false
            end
          end
        end
      end

      field :cache_keys_str, :text do
        weight 10
        visible do
          false #is_current_user_admin
        end
      end

    end
  end


end
