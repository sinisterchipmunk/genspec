class TestGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      if args.empty?
        m.file "file", "default_file"
      else
        m.file "file", args.first
      end
      
      m.template 'file', 'file_template'
      m.directory 'a_directory'
      
      m.class_collisions 'ActionController::Base'
      m.class_collisions 'SomethingValid'
      
      m.migration_template "file", "directory", :migration_file_name => 'migration'
      
      m.route_resources 'model'
      
      if options[:readme]
        m.readme 'file'
      end
    end
  end

  def add_options!(opt)
    opt.on('--readme') { |o| o[:readme] = true }
  end
end
