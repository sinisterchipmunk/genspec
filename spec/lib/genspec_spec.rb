require 'spec_helper'

describe GenSpec do
  include GenSpec::GeneratorExampleGroup
  generator :test_rails3
  with_args "one", "two"
  
  describe "with a custom root" do
    before { GenSpec.root = File.expand_path("../../tmp", File.dirname(__FILE__)) }
    after  { GenSpec.root = nil }
  
    it "should generate files in generation root" do
      within_source_root { expect(Dir[File.join(GenSpec.root, '**/*')]).not_to be_empty }
      expect(subject).to generate("a_directory")
    end
  end
end
