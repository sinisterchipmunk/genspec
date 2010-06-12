module GenSpec
  module GenerationMatchers
    class ResultMatcher < GenSpec::GenerationMatchers::GenerationMatcher
      attr_reader :filename
        
      def initialize(filename, &block)
        @filename = filename
        @block = block
        super(:does_not_matter)
      end
        
      def after_replay(target)
        path = File.join(target.destination_root, filename)
        if File.exist?(path)
          matched!
          validate_block(target, path)
        end
      end
        
      def failure_message
        "Expected to generate file #{filename}"
      end
        
      def negative_failure_message
        "Expected to not generate file #{filename}"
      end
        
      private
      def validate_block(target, path)
        if @block
          if @block.arity == 2
            @block.call(File.read(path), target)
          else
            @block.call(File.read(path))
          end
        else
          true
        end
      end
    end
  end
end
