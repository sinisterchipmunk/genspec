module GenSpec
  module Matchers
    class ResultMatcher < GenSpec::Matchers::Base
      attr_reader :filename
      
      def initialize(filename, &block)
        @filename = filename
        super(&block)
      end
      
      def generated
        if filename
          path = File.join(destination_root, filename)
          if File.exist?(path)
            match!
            spec_file_contents(path)
          end
        else
          # there was no error, so in the context of
          # "should generate", it most certainly
          # generated.
          match!
          if block
            block.call
          end
        end
      end
      
      def failure_message
        "Expected to generate #{filename}"
      end
        
      def failure_message_when_negated
        "Expected to not generate #{filename}"
      end
    end
  end
end
