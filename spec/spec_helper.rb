# Having ./support in the load path means Rails will load the generators at
# ./support/generators/**/*_generator.rb and
# ./support/rails/generators/**/*_generator.rb
$LOAD_PATH.push File.join(File.dirname(__FILE__), "support")
require File.join(File.dirname(__FILE__),"../../../config/environment")
require File.join(File.dirname(__FILE__),"../lib/gen_spec")

if Rails::VERSION::MAJOR < 3
  Rails::Generator::Base.append_sources Rails::Generator::PathSource.new(:test,
          File.expand_path("../support/generators", __FILE__))
end
