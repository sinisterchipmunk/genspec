require 'thor'
if defined?(Rails)
  if Rails::VERSION::MAJOR == 2
    raise "Use genspec 0.1.x for Rails 2; this version is for Rails 3."
  elsif Rails::VERSION::MAJOR == 3
    require 'rails/generators'
  else
    raise "Unsupported Rails version: #{Rails::VERSION::STRING}"
  end
end

begin
  require 'rspec/core'
rescue LoadError
  raise "GenSpec requires RSpec v2.0."
end

require 'fileutils'

require 'sc-core-ext'
require 'genspec/version'
require 'genspec/shell'
require 'genspec/matchers'
require 'genspec/generator_example_group'

# RSpec 2.0 compat
RSpec.configure do |config|
  config.include GenSpec::GeneratorExampleGroup, :example_group => { :file_path => /spec[\/]generators/ }
end
