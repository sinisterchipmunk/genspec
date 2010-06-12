require 'spec_helper'

# To make sure test environment is loading. Other successful tests will render
# this one redundant, so it's safe to remove.
#
# For those who would flame me, this gem evolved out of a bit of test code that
# was written for another project. Since the test code itself became a gem, I
# didn't necessarily have tests for my tests.
#
# Since I'm starting with a code base before the test environment exists, this
# file merely assures me that the test environment is loading.
#
describe "rails" do
  it "should be defined" do
    Rails
    GenSpec
  end
end
