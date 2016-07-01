require 'spec_helper'

if defined?(Rails)
  describe :my_migration do
    it "should run migration template" do
      # bug, raising NameError: undefined local variable or method `interceptor'
      expect(proc { expect(subject).to generate(:migration_template, "1", "2")
      }).not_to raise_error
    end
  end
end
