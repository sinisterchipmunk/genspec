require 'rubygems'
require 'bundler/gem_tasks'

def run(*args)
  exit $?.to_i unless system *args
end

task :default do
  run "rspec", "spec"
  ENV['RAILS'] = '1'
  run "rspec", "spec"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "genspec #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
