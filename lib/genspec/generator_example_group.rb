module GenSpec
  class GeneratorExampleGroup
    extend Spec::Example::ExampleGroupMethods
    include Spec::Example::ExampleMethods
    include GenSpec::GenerationMatchers
    delegate :generator_arguments, :generator_options, :generator_args, :to => "self.class"
    
    class << self
      def generator_arguments
        @generator_args.dup? || []
      end
      
      def generator_options
        @generator_options.dup? || {}
      end
      
      def with_arguments(*args, &block)
        if block_given?
          context "with arguments #{args.inspect}" do
            with_arguments(*args)
            instance_eval(&block)
          end
        else
          @generator_args = args.flatten.collect { |c| c.to_s }
        end
      end
      
      def with_options(hash, &block)
        if block_given?
          context "with options #{hash.inspect}" do
            with_options(hash)
            instance_eval(&block)
          end
        else
          @generator_options = hash
        end
      end
      
      alias_method :generator_args, :generator_arguments
      alias_method :with_args, :with_arguments
    end
    
    def subject(&block)
      block.nil? ?
        explicit_subject || implicit_subject : @explicit_subject_block = block
    end
  
    private
    def explicit_subject
      group = self
      while group.respond_to?(:explicit_subject_block)
        return group.explicit_subject_block if group.explicit_subject_block
        group = group.superclass
      end
    end
  
    def implicit_subject
      target = example_group_hierarchy[1].described_class || example_group_hierarchy[1].description_args.first
      
      if target.kind_of?(Symbol) || target.kind_of?(String)
        target = self.class.lookup_missing_generator("#{target.to_s.underscore}_generator".camelize)
      end
      target.new(generator_args, generator_options)
    rescue Rails::Generator::GeneratorError, Rails::Generator::UsageError
      # let them pass, so the user can test the output.
      # TODO: Make this disable-able via configuration.
      
      $! # return this because it is the content we'll check against.
    end
  end
end
