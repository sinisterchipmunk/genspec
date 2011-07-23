module GenSpec
  module Matchers
    class OutputMatcher < GenSpec::Matchers::Base
      def output
        shell.output.string
      end
      
      def initialize(text_or_regexp)
        regexp = if text_or_regexp.kind_of?(Regexp)
                   text_or_regexp
                 else
                   Regexp.compile(Regexp.escape(text_or_regexp), Regexp::MULTILINE)
                 end
        @regexp = regexp
        super()
        silence_errors!
      end
      
      def generated
        match! if output =~ @regexp
      end
      
      def failure_message
        output + "\n" \
          "expected to match #{@regexp.inspect}, but did not"
      end

      def negative_failure_message
        output + "\n" \
          "expected not to match #{@regexp.inspect}, but did"
      end
    end
  end
end