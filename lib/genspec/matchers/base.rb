module GenSpec
  module Matchers
    class Base
      attr_reader :block, :generator, :args, :described, :init_blocks
      attr_reader :destination_root
      attr_accessor :error
      
      def source_root
        generator.source_root
      end
      
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
        @shell = GenSpec::Shell.new("", generator[:input] || "")
        @init_blocks = generator[:init_blocks]
        
        if @described.kind_of?(Class)
          @generator = @described
        else
          if defined?(Rails)
            @generator = Rails::Generators.find_by_namespace(@described)
          else
            @generator = Thor::Util.find_by_namespace(@described)
          end
        end
        
        raise "Could not find generator: #{@described.inspect}" unless @generator
        
        inject_error_handlers!
        invoking
        invoke
        matched?
      ensure
        complete
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
      # callback fired after matching process is complete, regardless of success, failure
      # or error
      def complete
      end
      
      # callback which fires just before a generator has been invoked.
      # Allows matchers to inject whatever hooks they need into the generator.
      def invoking
      end
      
      # callback which fires just after a generator has run and after error checking has
      # been performed, if applicable.
      def generated
      end
      
      def spec_file_contents(filename)
        if @block
          content = File.read(filename)
          @block.call(content)
        end
      end
      
      def shell
        @shell
      end
      
      # Causes errors not to be raised if a generator fails. Useful for testing output,
      # rather than results.
      def silence_errors!
        @errors_silenced = true
      end
      
      private
      def check_for_errors
        # generation is complete - check for errors and re-raise it if it's there
        raise error if error && !@errors_silenced
      end
      
      def invoke
        Dir.mktmpdir do |tempdir|
          FileUtils.chdir tempdir do
            init_blocks.each do |block|
              block.call(tempdir)
            end
          
            @destination_root = tempdir
            stdout, stderr, stdin = $stdout, $stderr, $stdin
            $stdout, $stderr, $stdin = shell.output, shell.output, shell.input

            begin
              @generator.start(@args || [], {
                :shell => @shell,
                :destination_root => destination_root
              })
            ensure
              $stdout, $stderr, $stdin = stdout, stderr, stdin
            end
          
            check_for_errors
            generated
          end
        end
      end
      
      def inject_error_handlers!
        interceptor = self
        @generator.class_eval do
          no_tasks do
            def invoke_with_genspec_error_handler(*names, &block)
              invoke_without_genspec_error_handler(*names, &block)
            rescue Thor::Error => err
              # self.class.interceptor.error = err
              interceptor.error = err
              raise err
            end
          
            alias invoke_without_genspec_error_handler invoke
            alias invoke invoke_with_genspec_error_handler
          end
        end
      end
    end
  end
end
