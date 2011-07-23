module GenSpec
  module Matchers
    class ResultMatcher < GenSpec::Matchers::Base
      attr_reader :filename
      
      def initialize(filename, &block)
        @filename = filename
        super(&block)
      end
      
      def generated
        path = File.join(destination_root, filename)
        if File.exist?(path)
          match!
          spec_file_contents(path)
        end
      end
      
      def failure_message
        "Expected to generate #{filename}"
      end
        
      def negative_failure_message
        "Expected to not generate #{filename}"
      end
    end
  end
end
