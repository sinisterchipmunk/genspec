require 'spec_helper'

shared_examples_for 'the question generator' do
  context "without input" do
    it "should raise an error" do
      expect(proc { expect(subject).to output("Are you a GOD?")
      }).to raise_error
    end
  end
  
  with_input "yes" do
    it "should act upon something" do
      expect(subject).to act_upon("something")
      expect(subject).to output(/Acted upon something/)
    end
    
    it "should not raise an error" do
      expect(proc { expect(subject).to output("Good.") }).not_to raise_error
    end
  end

  with_input "no" do
    it "should act upon something" do
      expect(subject).to act_upon("something")
      expect(subject).to output(/Acted upon something/)
    end
    
    it "should not raise an error" do
      expect(proc { expect(subject).to output("You're new around here, aren't you?")
      }).not_to raise_error
    end
  end
end

# test that we can pass a generator by class, there's no reason this shouldn't
# be possible
describe Question do
  it_should_behave_like 'the question generator'
end

describe :question do
  it_should_behave_like 'the question generator'
end
