require 'thor'
if defined?(Rails)
  if Rails::VERSION::MAJOR == 2
    raise "Use genspec 0.1.x for Rails 2; this version is for Rails 3."
  elsif [3, 4, 5].include? Rails::VERSION::MAJOR
    require 'rails/generators'
  else
    raise "Unsupported Rails version: #{Rails::VERSION::STRING}"
  end
end

begin
  require 'rspec/core'
  require 'rspec/version'
rescue LoadError
  raise "GenSpec requires RSpec v2.0 or newer."
end

require 'fileutils'

module GenSpec
  def self.root;        @root;        end
  def self.root=(root); @root = root; end

  require 'genspec/version' unless defined?(GenSpec::VERSION)
  require 'genspec/shell'
  require 'genspec/matchers'
  require 'genspec/generator_example_group'
end

RSpec.configure do |config|
  if RSpec::Version::STRING[0] == '2'
    config.include GenSpec::GeneratorExampleGroup, example_group: { file_path: /spec[\/]generators/ }
  elsif RSpec::Version::STRING[0] == '3'
    config.include GenSpec::GeneratorExampleGroup, file_path: /spec[\/]generators/
  else
    raise "unexpected rspec version: #{RSpec::Version::STRING}"
  end
  
  # Kick off the action wrappers.
  #
  # This has to be deferred until the specs run so that the
  # user has a chance to add custom action modules to the 
  # list.
  config.before(:each) do
    if self.class.include?(GenSpec::GeneratorExampleGroup) # if this is a generator spec
      GenSpec::Matchers.add_shorthand_methods(self.class)
    end
  end
end
