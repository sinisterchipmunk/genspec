require 'rubygems'
require 'rake'
begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue MissingSourceFile
  module RSpec
    module Core
      class RakeTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

def rcov_opts
  IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "genspec"
    gem.summary = "Simple, expressive Rails 3 generator testing for RSpec. For the Rails 2.3 version, use genspec 0.1.x."
    gem.description = "Simple, expressive Rails 3 generator testing for RSpec. For the Rails 2.3 version, use genspec 0.1.x."
    gem.email = "sinisterchipmunk@gmail.com"
    gem.homepage = "http://www.thoughtsincomputation.com"
    gem.authors = ["Colin MacKenzie IV"]
    gem.files = FileList['**/*']
    gem.add_dependency "rspec", ">= 2.0.0.beta.14"
    gem.add_dependency "sc-core-ext", ">= 1.2.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = false
end

desc "Spec coverage"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'vendor/cache/genspec/spec/**/*_spec.rb'
#  t.spec_opts = ['--options', 'spec/spec.opts']
  t.rcov = true
  t.rcov_path = 'coverage'
  t.rcov_opts = rcov_opts
end

task :default => [:check_dependencies, :spec]

#desc "rebuilds the package and then copies the .gem file back a directory"
#task :bundle => :build do
#  Dir["../cache/genspec-*.gem"].each { |f| rm File.expand_path(f) }
#  Dir["pkg/*.gem"].each { |f| cp File.expand_path(f), File.expand_path('../cache') }
#end
#
#namespace :bundle do
#  desc "builds and installs the gem, then runs bundle package, then uninstalls the gem"
#  task :lock => [:install, :rebundle, :uninstall]
#  
#  desc "runs 'bundle package' in the rails project"
#  task :rebundle do
#    chdir File.expand_path(File.join(File.dirname(__FILE__), "../..")) do
#      system("bundle package")
#    end
#  end
#  
#  desc "uninstalls the gem"
#  task :uninstall do
#    system("gem uninstall genspec")
#  end
#end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "genspec #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
