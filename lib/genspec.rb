require 'spec'
require 'fileutils'

require 'sc-core-ext'

require 'genspec/generation_matchers'
require 'genspec/generator_example_group'

if defined?(RAILS_ROOT)
  require 'rails_generator'
  require 'rails_generator/scripts/generate'
end

Spec::Example::ExampleGroupFactory.register(:generator, GenSpec::GeneratorExampleGroup)
