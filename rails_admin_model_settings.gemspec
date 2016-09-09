# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_admin_model_settings/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_admin_model_settings"
  spec.version       = RailsAdminModelSettings::VERSION
  spec.authors       = ["Alexander Kiseliev"]
  spec.email         = ["dev@redrocks.pro"]

  spec.summary       = %q{rails_admin_model_settings}
  spec.description   = %q{rails_admin_model_settings}
  spec.homepage      = "https://github.com/red-rocks/rails_admin_model_settings"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rails", '>= 5.0.0'


  spec.add_dependency "ack_rails_admin_settings", '~> 1.1'
  spec.add_dependency 'rails_admin', '>= 1.0.0.rc'
  spec.add_dependency "mongoid", [">=  6.0.0.rc0", "< 7.0"]
end
