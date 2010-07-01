if defined?(RAILS_ROOT)
  if Rails::VERSION::MAJOR == 2
    raise "Use genspec 0.1.0 for Rails 2; this version is for Rails 3."
  elsif Rails::VERSION::MAJOR == 3
    require 'rails/generators'
  else
    raise "Unsupported Rails version: #{Rails::VERSION::STRING}"
  end
end

require 'rspec/core'
require 'fileutils'

require 'sc-core-ext'
require 'genspec/shell'
require 'genspec/matchers'
require 'genspec/generator_example_group'

Thor::Base.shell = GenSpec::Shell.new

# RSpec 2.0 compat
RSpec.configure do |config|
  config.include GenSpec::GeneratorExampleGroup, :example_group => { :file_path => /spec[\/]generators/ }
end
