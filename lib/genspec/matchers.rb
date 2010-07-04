require 'genspec/matchers/base'
require 'genspec/matchers/result_matcher'
require 'genspec/matchers/generation_method_matcher'
require 'genspec/matchers/output_matcher'

module GenSpec
  module Matchers
    # Valid types: :dependency, :class_collisions, :file, :template, :complex_template, :directory, :readme,
    # :migration_template, :route_resources
    def generate(kind, *args, &block)
      if kind.kind_of?(Symbol)
        call_action(kind, *args, &block)
      else
        GenSpec::Matchers::ResultMatcher.new(kind, &block)
      end
    end
    
    def call_action(kind, *args, &block)
      unless matcher = GenSpec::Matchers::GenerationMethodMatcher.for_method(kind, *args, &block)
        raise "Could not find a matcher for '#{kind.inspect}'!\n\n" \
              "If this is a custom action, try adding the Thor Action module to GenSpec:\n\n" \
              "GenSpec::Matchers::GenerationMethodMatcher::GENERATION_CLASSES << 'My::Actions'"
      end
      matcher
    end
    
    # This tests the content sent to the command line, instead of the generated product.
    # Useful for testing help messages, etc.
    def output(text_or_regexp)
      GenSpec::Matchers::OutputMatcher.new(text_or_regexp)
    end
    
    class << self
      def add_shorthand_methods(base)
        instance_methods = base.instance_methods.collect { |m| m.to_s }
        GenSpec::Matchers::GenerationMethodMatcher.generation_methods.each do |method_name|
          # don't overwrite existing methods. since the user expects this to fire FIRST,
          # it's as if this method's been "overridden".
          next if instance_methods.include?(method_name)
          base.class_eval <<-end_code
            def #{method_name}(*args, &block)                    # def create_file(*args, &block)
              call_action(#{method_name.inspect}, *args, &block) #   call_action('create_file', *args, &block)
            end                                                  # end
          end_code
        end 
      end
      
      # this is to delay definition of the generation method matchers (like #create_file) until
      # after initialization, in order to facilitate custom Thor actions.
      def included(base)
        add_shorthand_methods(base)
      end
      
      def extended(base)
        add_shorthand_methods(class << base; self; end)
      end
    end
  end
end
