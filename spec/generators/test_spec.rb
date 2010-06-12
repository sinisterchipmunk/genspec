require 'spec_helper'

describe :test do
  context "with no options or arguments" do
    it "should generate a file called default_file" do
      subject.should generate("default_file")
      subject.should_not generate("some_other_file")
      
      subject.should generate(:file)
      subject.should generate(:file, "file", "default_file")
    end
    
    it "should generate a file with specific content" do
      subject.should generate("default_file") { |content| content.should == "content!" }
      subject.should generate("default_file") { |content| content.should_not == "!content" }
      subject.should_not generate("some_other_file")
    end
    
    it "should check for class collisions" do
      subject.should generate(:class_collisions)
      subject.should generate(:class_collisions, 'ActionController::Base')
      subject.should_not generate(:class_collisions, 'ActionController')
      subject.should generate(:class_collisions, 'SomethingValid')
    end
    
    it "should generate a template called 'default_template'" do
      subject.should generate(:template)
      subject.should generate(:template, 'file', 'file_template')
    end
    
    it "shoud generate a directory called 'a_directory'" do
      subject.should generate(:directory)
      subject.should generate(:directory, "a_directory")
      subject.should generate("a_directory")
      subject.should_not generate(:directory, 'another_directory')
    end
    
    it "should generate a migration template" do
      subject.should generate(:migration_template, "file", "directory", :migration_file_name => 'migration')
      # Uh, is there an easier, not-so-internally-dependent way to see if migration templates are generated?
    end
    
    it "should generate resource routes" do
      subject.should generate(:route_resources, 'model')
    end
    
    it "should generate a readme" do
      # we have to silence stdout because readme prints to stdout. Duh, right?
      # That's also the reason for the :readme option. That way we can default it to 'disabled' for all other
      # tests.
      stdout = $stdout
      $stdout = StringIO.new("")
      self.class.with_options :readme => true
      subject.should generate(:readme)
      subject.should generate(:readme, "file")
      $stdout = stdout
    end
  end
  
  context "with options" do
    with_options :help => true do
      it "should generate 'Rails Info:'" do
        subject.should output("Rails Info:")
      end
      
      it "should generate 'Rails Info:'" do
        subject.should output(/rails info\:/i)
      end
    end
  end
  
  context "with arguments" do
    with_args :test_arg
    
    it "should generate a :file from template 'file' to file 'test_arg'" do
      subject.should generate(:file, "file", "test_arg")
    end
    
    it "should generate file 'test_arg'" do
      subject.should generate('test_arg')
    end
  end

  # FIXME: Uh, how best to write a spec around this? I'm actually trying to test #with_args with a block...
  with_args :test_arg do
    it "should generate file 'test_arg'" do
      subject.should generate('test_arg')
    end
  end
  
  with_options :help => true do
    it "should generate 'Rails Info:'" do
      subject.should output("Rails Info:")
    end
  end
end
