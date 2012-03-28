require 'spec_helper'

describe GenSpec do
  include GenSpec::GeneratorExampleGroup
  generator :test_rails3
  with_args "one", "two"
  
  describe "with a custom root" do
    before { GenSpec.root = File.expand_path("../../tmp", File.dirname(__FILE__)) }
    after  { GenSpec.root = nil }
  
    it "should generate files in generation root" do
      within_source_root { Dir[File.join(GenSpec.root, '**/*')].should_not be_empty }
      subject.should generate("a_directory")
    end
  end
end
