base = defined?(Rails) ? Rails::Generators::Base : Thor::Group

class TestRails3 < base
  include Thor::Actions
  
  def self.source_root
    File.expand_path('../templates', __FILE__)
  end

  argument :argument1, :type => :string, :default => "default_file" 
  argument :template_name, :type => :string, :default => "file_template"
  
  def gen_file_with_arg
    create_file argument1, "content!"
  end
  
  def gen_directory
    empty_directory "a_directory"
  end
  
  def gen_template
    template 'file', template_name
  end
  
  def gen_gem_source
    if File.file?("Gemfile")
      if defined?(Rails)
        add_source "http://gems.github.com/"
      else
        append_file "Gemfile", 'source "http://gems.github.com/"'
      end
    end
  end
end
