require 'coveralls'
Coveralls.wear!

# Having ./support in the load path means Rails will load the generators at
# ./support/generators/**/*_generator.rb and
# ./support/rails/generators/**/*_generator.rb
$LOAD_PATH.push File.join(File.dirname(__FILE__), "support")

require 'bundler'
Bundler.setup

if ENV['USE_RAILS']
  require 'rails'
  require 'rails/generators'
end  

module CustomActions
  def act_upon(file)
    say "Acted upon #{file}."
  end
end

if !defined?(Rails)
  require 'thor/group'
  require File.expand_path('support/generators/test_rails3/test_rails3_generator', File.dirname(__FILE__))
  require File.expand_path('support/generators/question/question_generator', File.dirname(__FILE__))
end

RSpec.configure do |c|
  c.before { GenSpec.root = File.expand_path('../tmp', File.dirname(__FILE__)) } if RUBY_PLATFORM =~ /java/i
end

require File.join(File.dirname(__FILE__),"../lib/gen_spec")
GenSpec::Matchers::GenerationMethodMatcher::GENERATION_CLASSES << "CustomActions"
