# RailsAdminModelSettings

Do your models and [AckRailsAdminSettings](https://github.com/red-rocks/rails_admin_settings) cooperation is more easy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_admin_model_settings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_model_settings

## Usage

Add this into your model:
    include RailsAdminModelSettings::ModelSettingable

and use it for access to mongoid collection of model settings
    YourModel.rails_admin_model_settings.where(key: 'some_key')

or as wrapper for Settings
    YourModel.settings.some_setting(kind: :html, default: "<p></p>")

Also add 'model_settings' action into your rails_admin config and it will add list of settings for current model in rails_admin panel;

### Advanced

Default ns for AckRailsAdminSettings is "rails_admin_model_settings_#{underscored_model_name}" so you can use it like this
```ruby
module RailsAdminSettings
  class Setting

    after_save do |record|
      case record.ns
      when /^rails_admin_model_settings_/
        _ns = record.ns.sub("rails_admin_model_settings_", "")
        case _ns
        when 'this_model'
          do_something
        when 'that_model'
          do_something_else
        end
      end

    end

  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/red-rocks/rails_admin_model_settings.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
