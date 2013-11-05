require 'rubygems'
require 'bundler/gem_tasks'

def run(*args)
  raise "tests failed" unless system *args
end

require 'coveralls/rake/task'
Coveralls::RakeTask.new

task :default do
  run "rspec", "spec"
  ENV['USE_RAILS'] = '1'
  run "rspec", "spec"
  Rake::Task['coveralls:push'].invoke
end

begin
  require "rdoc/task"
rescue LoadError
  require 'rake/rdoctask'
end

Rake::RDocTask.new do |rdoc|
  version = GenSpec::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "genspec #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
