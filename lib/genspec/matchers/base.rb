module GenSpec
  module Matchers
    class Base
      attr_reader :block, :generator, :args, :described
      delegate :source_root, :to => :generator
      attr_reader :destination_root
      attr_accessor :error
      
      def initialize(&block)
        @block = block if block_given?
        @matched = false
      end
      
      def match!
        @matched = true
      end
      
      def matches?(generator)
        @described = generator[:described]
        @args = generator[:args]
        
        if @described.kind_of?(Array)
          @generator = Rails::Generators.find_by_namespace(*@described)
        else
          @generator = Rails::Generators.find_by_namespace(@described)
        end
        
        raise "Could not find generator: #{@described.inspect}" unless @generator
        
        localize_generator!
        inject_error_handlers!
        invoking
        invoke
        matched?
      end
      
      def matched?
        @matched
      end
    
      def failure_message
        "was supposed to match and didn't"
      end
        
      def negative_failure_message
        "was supposed to not match and did"
      end
      
      protected
      # callback which fires just before a generator has been invoked.
      def invoking
      end
      
      # callback which fires just after a generator has run and after error checking has
      # been performed, if applicable.
      def generated
      end
      
      def temporary_root
        Dir.mktmpdir do |dir|
          # need to copy a few files for some methods, ie route_resources
          FileUtils.touch(File.join(dir, "Gemfile"))
          
          # all set.
          yield dir
        end
      end
      
      def spec_file_contents(filename)
        if @block
          content = File.read(filename)
          @block.call(content)
        end
      end
      
      protected
      # Causes errors not to be raised if a generator fails. Useful for testing output,
      # rather than results.
      def silence_errors!
        @errors_silenced = true
      end
      
      def silence_thor!
        @generator.instance_eval do
          alias thor_method_added method_added

          # to silence callbacks and errors about reserved keywords
          def method_added(meth)
          end
        end
        
        yield
        
        # un-silence errors and callbacks
        @generator.instance_eval { alias thor_method_added method_added }
      end
      
      private
      def check_for_errors
        # generation is complete - check for errors and re-raise it if it's there
        raise error if error && !@errors_silenced
      end
      
      def invoke
        temporary_root do |tempdir|
          @destination_root = tempdir
          @generator.start(@args || [], {:destination_root => destination_root})
          check_for_errors
          generated
        end
      end
      
      def inject_error_handlers!
        silence_thor! do
          @generator.class_eval do
            def invoke_with_genspec_error_handler(*names, &block)
              invoke_without_genspec_error_handler(*names, &block)
            rescue Thor::Error => err
              self.class.interceptor.error = err
              raise err
            end
            
            alias invoke_without_genspec_error_handler invoke
            alias invoke invoke_with_genspec_error_handler
          end
        end
      end
      
      def localize_generator!
        # subclass the generator in question so that aliasing its methods doesn't
        # impact the root generator (which would be a Bad Thing for other specs)
        gen = @generator
        generator = Class.new(gen)
        # we have to force the name in order to avoid nil errors within Thor.
        generator.instance_eval "def self.name; #{gen.name.inspect}; end"
        @generator = generator

        
        # add self as the "interceptor" so that our generator's wrapper methods can
        # gain access to this object.
        def @generator.interceptor; @interceptor; end
        def @generator.interceptor=(a); @interceptor = a; end
    
        @generator.interceptor = self
      end
    end
  end
end
