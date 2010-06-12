require 'genspec/generation_matchers/generation_matcher'
require 'genspec/generation_matchers/result_matcher'

module GenSpec
  module GenerationMatchers
    # Valid types: :dependency, :class_collisions, :file, :template, :complex_template, :directory, :readme,
    # :migration_template, :route_resources
    def generate(kind, *args, &block)
      case kind.to_s
        when *GenSpec::GenerationMatchers::GenerationMatcher.generation_methods
          GenSpec::GenerationMatchers::GenerationMatcher.new(kind, *args, &block)
        else
          if kind.kind_of?(String)
            GenSpec::GenerationMatchers::ResultMatcher.new(kind, &block)
          else
            raise ArgumentError, "No generator matcher for #{kind.inspect}"
          end
      end
    end
    
    # This tests the content sent to the command line, instead of the generated product.
    # Useful for testing help messages, etc.
    def output(text_or_regexp)
      GenSpec::GenerationMatchers::GenerationMatcher.new(:output, text_or_regexp)
    end
  end
end
