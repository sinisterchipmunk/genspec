module GenSpec
  module GeneratorExampleGroup
    include RSpec::Matchers
    include GenSpec::Matchers

    def self.included(base)
      base.send(:extend, GenSpec::GeneratorExampleGroup::ClassMethods)
      base.send(:subject) { generator_descriptor }
    end
    
    def within_source_root(&block)
      generator_init_blocks << block
    end
    
    def generator_init_blocks
      @generator_init_blocks ||= self.class.generator_init_blocks.dup
    end
    
    # A hash containing the following:
    #
    #   :described   - the generator to be tested, or the string/symbol representing it
    #   :args        - any arguments to be used when invoking the generator
    #   :input       - a string to be used as an input stream, or nil
    #   :init_blocks - an array of blocks to be invoked prior to running the generator
    #   :generator_options - a hash of options to be passed into the generator
    #
    # This hash represents the +subject+ of the spec and this is the object that will
    # ultimately be passed into the GenSpec matchers.
    #
    def generator_descriptor
      {
        :described => self.class.generator,
        :args => self.class.generator_args,
        :input => self.class.generator_input,
        :output => self.class.generator_output,
        :init_blocks => generator_init_blocks,
        :generator_options => self.class.generator_options
      }
    end
    
    module ClassMethods
      # Sets the list of arguments for this generator.
      #
      # * All arguments will be converted to Strings, because that's how
      #   they'd enter the generator from a command line. To avoid this,
      #   pass :object => true at the end;
      #
      # Ex:
      #
      #   with_args '--orm', 'active_record' do
      #     it "should use activerecord" do
      #       # . . .
      #     end
      #   end
      #
      #   with_args '--size', 5, :object => true do
      #     # . . .
      #   end
      #
      def with_args(*args, &block)
        options = args.extract_options!
        args = args.flatten.collect { |c| c.to_s } unless options[:object]
        
        if block_given?
          context "with arguments #{args.inspect}" do
            with_args(generator_args + args, options)
            instance_eval(&block)
          end
        else
          metadata[:generator_args] = args
        end
      end
      
      # Allows you to pass options directly into the generator, such as
      # :shell, :behavior, etc.
      #
      # Ex:
      #
      #   # simulate a destroy generator, per `rails destroy controller ...`
      #   with_generator_options :behavior => :revoke do
      #     # . . .
      #   end
      #
      def with_generator_options(options, &block)
        if block_given?
          context "with generator options #{options.inspect}" do
            with_generator_options options
            instance_eval &block
          end
        else
          generator_options.merge! options
        end
      end
      
      # Sets the input stream for this generator.
      #
      # Ex:
      #
      #   with_input <<-end_input do
      #     y
      #     n
      #     a
      #   end_input
      #     it "should overwrite, then skip, then overwrite all" do
      #       # . . .
      #     end
      #   end
      #
      def with_input(string, &block)
        if block_given?
          context "with input string #{string.inspect}" do
            with_input string
            instance_eval &block
          end
        else
          metadata[:generator_input] = string
        end
      end
      
      # Executes some code within the generator's source root
      # prior to the generator actually running. Useful for
      # setting up fixtures.
      #
      # Ex:
      #
      #   within_source_root do
      #     touch "Gemfile"
      #   end
      #
      # Optionally, the block may receive a single argument,
      # which is the full path to the temporary directory
      # representing the source root:
      #
      #   within_source_root do |tempdir|
      #     # . . .
      #   end
      #
      def within_source_root(&block)
        metadata[:generator_init_block] = block
      end
      
      # Returns an array of all init blocks from the topmost context down to this
      # one, in that order. These blocks will be executed sequentially prior to
      # each run of the generator.
      def generator_init_blocks
        result = []
        result.concat superclass.generator_init_blocks if genspec_subclass?
        result << metadata[:generator_init_block] if metadata[:generator_init_block]
        result
      end
      
      # Returns the generator arguments to be used for this context. If this context doesn't
      # have any generator arguments, its superclass is checked, and so on until either the
      # parent isn't a GenSpec or a set of arguments is found. Only the closest argument
      # set is used; any sets specified above the discovered argument set are
      # ignored.
      def generator_args
        return metadata[:generator_args] if metadata[:generator_args]
        
        metadata[:generator_args] = if genspec_subclass?
          superclass.generator_args
        else
          []
        end
      end
      
      # Returns the hash of options to be passed into the generator in this context.
      def generator_options
        return metadata[:generator_options] if metadata[:generator_options]
        
        metadata[:generator_options] = if genspec_subclass?
          superclass.generator_options.dup
        else
          { }
        end
      end
      
      # Returns the generator output string or IO, or nil.
      def generator_output
        return metadata[:generator_output] if metadata[:generator_output]
        
        metadata[:generator_output] = if genspec_subclass?
          superclass.generator_output
        else
          nil
        end
      end
      
      # Returns the input stream to be used for this context. If this context doesn't
      # have an input stream, its superclass is checked, and so on until either the
      # parent isn't a GenSpec or an input stream is found. Only the closest input
      # stream is used; any streams specified above the discovered input stream are
      # ignored.
      def generator_input
        return metadata[:generator_input] if metadata[:generator_input]
        
        metadata[:generator_input] = if genspec_subclass?
          superclass.generator_input
        else
          nil
        end
      end
      
      alias before_generation   within_source_root
      alias with_arguments      with_args
      alias generator_arguments generator_args
      
      # Traverses up the context tree to find the topmost description, which represents
      # the controller to be tested or the string/symbol representing it.
      #
      # If name is specified, it will be used instead and subsequent calls to this method
      # will return the specified name.
      def generator(name = nil)
        metadata[:generator_name] = name.to_s if name
        return metadata[:generator_name] if metadata[:generator_name]
        
        if genspec_subclass?
          superclass.generator
        else
          describes || description
        end
      end

      # Returns true if this object's superclass is also a GenSpec.
      #
      # When a context is created, rspec creates a class inheriting from the context's
      # parent. Therefore, this method can be used to recurse up to the highest-level
      # spec that still tests a generator.
      def genspec_subclass?
        superclass.include?(GenSpec::GeneratorExampleGroup)
      end
    end
  end
end
