require 'spec_helper'

describe :test_rails3 do
  within_source_root do
    FileUtils.touch "Gemfile"
  end
  
  it "should modify Gemfile" do
    out = ""
    expect(subject).to generate {
      expect(File.read("Gemfile").strip).not_to be_empty
      out.concat File.read("Gemfile")
    }
    expect(out.strip).to match %r(\Asource ['"]http://gems.github.com/['"]\z)
  end
  
  context "with no options or arguments" do
    it "should generate a file called default_file" do
      expect(subject).to     generate("default_file")
      expect(subject).not_to generate("some_other_file")
      
      expect(subject).to     call_action(:create_file)
      expect(subject).to     call_action(:create_file, "default_file")
      expect(subject).not_to call_action(:create_file, "some_other_file")
      
      expect(subject).to     create_file
      expect(subject).to     create_file('default_file')
      expect(subject).not_to create_file("some_other_file")
    end
    
    it "should generate a file with specific content" do
      expect(subject).to generate("default_file") { |content| expect(content).to eq "content!" }
      expect(subject).to generate("default_file") { |content| expect(content).not_to eq "!content" }
      expect(subject).not_to generate("some_other_file")
    end
    
    it "should generate a template called 'default_template'" do
      expect(subject).to generate(:template)
      expect(subject).to generate(:template, 'file', 'file_template')
    end
    
    it "should output 'create    file'" do
      expect(subject).to output(/create\s+default_file/)
    end
    
    it "shoud generate a directory called 'a_directory'" do
      expect(subject).to     generate(:empty_directory)
      expect(subject).to     generate(:empty_directory, "a_directory")
      expect(subject).to     generate("a_directory")
      expect(subject).not_to generate(:empty_directory, 'another_directory')
      expect(subject).to     empty_directory("a_directory")
      expect(subject).not_to empty_directory("another_directory")
    end
    
    # if the other tests pass then it seems to be working properly, but let's make sure
    # Rails-specific actions are also working. If they are, it's safe to say custom extensions
    # will work fine too.
    it 'should add_source "http://gems.github.com/"' do
      if GenSpec.rails?
        expect(subject).to add_source("http://gems.github.com/")
      end
    end
  end
  
  with_args '--help' do
    it "should output usage banner with string" do
      expect(subject).to output(" test_rails3 [ARGUMENT1]")
    end
    
    it "should output usage banner with regexp" do
      expect(subject).to output(/ test_rails3 /)
    end
  end
  
  context "with arguments without block" do
    with_args :test_arg
    
    it "should generate file 'test_arg'" do
      expect(subject).to generate('test_arg')
    end
  end

  with_args :test_arg do
    it "should generate file 'test_arg'" do
      expect(subject).to generate('test_arg')
    end
    
    it "should not generate template_name" do
      # because that option hasn't been given in this context.
      expect(subject).not_to generate('template_name')
    end
    
    with_generator_options :behavior => :revoke do
      it "should delete file 'test_arg'" do
        expect(subject).to generate {
          expect(File).not_to exist("test_arg")
        }
      end
      
      # demonstrate use of the `delete` matcher, which is equivalent to
      # above:
      it "should destroy file 'test_arg'" do
        expect(subject).to delete("test_arg")
      end
    end
    
    # ...and a test of nested args
    with_args "template_name" do
      it "should generate file 'test_arg'" do
        expect(subject).to generate('test_arg')
      end

      it "should generate file 'template_name'" do
        expect(subject).to generate("template_name")
      end
    end
  end
end
