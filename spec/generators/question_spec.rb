require 'spec_helper'

describe :question do
  context "without input" do
    it "should raise an error" do
      proc { subject.should output("Are you a GOD?") }.should raise_error
    end
  end
  
  with_input "yes" do
    it "should act upon something" do
      subject.should act_upon("something")
      subject.should output(/Acted upon something/)
    end
    
    it "should not raise an error" do
      proc { subject.should output("Good.") }.should_not raise_error
    end
  end

  with_input "no" do
    it "should act upon something" do
      subject.should act_upon("something")
      subject.should output(/Acted upon something/)
    end
    
    it "should not raise an error" do
      proc { subject.should output("You're new around here, aren't you?") }.should_not raise_error
    end
  end
end
