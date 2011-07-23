require 'rails/generators/active_record'

class MyMigrationGenerator < ActiveRecord::Generators::Base
  def initialize(args, *options)
    super(["unused"]+args, *options)
  end

  def generate_migration
    migration_template "1", "2"
  end
end
