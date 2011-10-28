require 'spec_helper'

describe :test_rails3 do
  within_source_root do
    FileUtils.touch "Gemfile"
  end
  
  it "should modify Gemfile" do
    out = ""
    subject.should generate {
      File.read("Gemfile").strip.should_not be_blank
      out.concat File.read("Gemfile")
    }
    out.strip.should == 'source "http://gems.github.com/"'
  end
  
  context "with no options or arguments" do
    it "should generate a file called default_file" do
      subject.should     generate("default_file")
      subject.should_not generate("some_other_file")
      
      subject.should     call_action(:create_file)
      subject.should     call_action(:create_file, "default_file")
      subject.should_not call_action(:create_file, "some_other_file")
      
      subject.should     create_file
      subject.should     create_file('default_file')
      subject.should_not create_file("some_other_file")
    end
    
    it "should generate a file with specific content" do
      subject.should generate("default_file") { |content| content.should == "content!" }
      subject.should generate("default_file") { |content| content.should_not == "!content" }
      subject.should_not generate("some_other_file")
    end
    
    it "should generate a template called 'default_template'" do
      subject.should generate(:template)
      subject.should generate(:template, 'file', 'file_template')
    end
    
    it "should output 'create    file'" do
      subject.should output(/create\s+default_file/)
    end
    
    it "shoud generate a directory called 'a_directory'" do
      subject.should     generate(:empty_directory)
      subject.should     generate(:empty_directory, "a_directory")
      subject.should     generate("a_directory")
      subject.should_not generate(:empty_directory, 'another_directory')
      subject.should     empty_directory("a_directory")
      subject.should_not empty_directory("another_directory")
    end
    
    # if the other tests pass then it seems to be working properly, but let's make sure
    # Rails-specific actions are also working. If they are, it's safe to say custom extensions
    # will work fine too.
    it 'should add_source "http://gems.github.com/"' do
      if defined?(Rails)
        subject.should add_source("http://gems.github.com/")
      end
    end
  end
  
  with_args '--help' do
    it "should output usage banner with string" do
      subject.should output(" test_rails3 [ARGUMENT1]")
    end
    
    it "should output usage banner with regexp" do
      subject.should output(/ test_rails3 /)
    end
  end
  
  context "with arguments without block" do
    with_args :test_arg
    
    it "should generate file 'test_arg'" do
      subject.should generate('test_arg')
    end
  end

  # FIXME: Uh, how best to write a spec around this? I'm actually trying to test #with_args with a block...
  with_args :test_arg do
    it "should generate file 'test_arg'" do
      subject.should generate('test_arg')
    end
    
    # ...and a test of nested args
    with_args "template_name" do
      it "should generate file 'test_arg'" do
        subject.should generate('test_arg')
      end

      it "should generate file 'template_name'" do
        subject.should generate("template_name")
      end
    end
  end
end
