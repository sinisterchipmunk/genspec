# Having ./support in the load path means Rails will load the generators at
# ./support/generators/**/*_generator.rb and
# ./support/rails/generators/**/*_generator.rb
$LOAD_PATH.push File.join(File.dirname(__FILE__), "support")

require 'bundler'
Bundler.setup

if ENV['RAILS']
  require 'rails'
  require 'rails/generators'
end  

if !defined?(Rails)
  require 'thor/group'
  require File.expand_path('support/generators/test_rails3/test_rails3_generator', File.dirname(__FILE__))
end

require File.join(File.dirname(__FILE__),"../lib/gen_spec")
