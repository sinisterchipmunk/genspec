require File.expand_path("../../../../../config/environment", __FILE__)

Rails::Generator::Base.append_sources Rails::Generator::PathSource.new(:test,
        File.expand_path("../support/generators", __FILE__))
