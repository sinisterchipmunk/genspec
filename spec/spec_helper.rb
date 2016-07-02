require 'coveralls'
Coveralls.wear_merged!

# Having ./support in the load path means Rails will load the generators at
# ./support/generators/**/*_generator.rb and
# ./support/rails/generators/**/*_generator.rb
$LOAD_PATH.push File.join(File.dirname(__FILE__), "support")

require 'bundler'
Bundler.setup

if ENV['RAILS_VERSION'] != 'none'
  require 'rails'
  require 'rails/generators'
elsif ENV['DEFINE_RAILS_MODULE']
  # Rails module can be defined while missing common constants like VERSION
  # if you pull in a rails component like ActiveRecord, then require the
  # activerecord generators. Maybe this can happen in other scenarios too.
  # Anyway the existence of a Rails module alone should not break genspec.
  module Rails; end
end

module CustomActions
  def act_upon(file)
    say "Acted upon #{file}."
  end
end

require 'genspec'
unless GenSpec.rails?
  require 'thor/group'
  require File.expand_path('support/generators/test_rails3/test_rails3_generator', File.dirname(__FILE__))
  require File.expand_path('support/generators/question/question_generator', File.dirname(__FILE__))
end

if RSpec::Expectations.respond_to?(:configuration)
  RSpec::Expectations.configuration.on_potential_false_positives = :nothing
end

RSpec.configure do |c|
  c.before { GenSpec.root = File.expand_path('../tmp', File.dirname(__FILE__)) } if RUBY_PLATFORM =~ /java/i
end

require File.join(File.dirname(__FILE__),"../lib/gen_spec")
GenSpec::Matchers::GenerationMethodMatcher::GENERATION_CLASSES << "CustomActions"
