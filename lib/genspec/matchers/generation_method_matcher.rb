class GenSpec::Matchers::GenerationMethodMatcher < GenSpec::Matchers::Base
  # The modules whose public instance methods will be converted into GenSpec matchers.
  # See #generation_methods for details.
  #
  # By default, this includes all of the following:
  #
  # * +Thor::Actions+
  # * +Rails::Generators::Actions+
  # * +Rails::Generators::Migration+
  #
  # If Rails has not been loaded, (e.g. you are testing Thor generators, not Rails generators),
  # the Rails modules are silently ignored.
  #
  # You can add any additional modules to this list. Note that you should list them 
  # in the form of a String representing the module name, rather than adding the modules
  # themselves. This allows you to add them prior to actually load them.
  #
  # This will only take effect _before_ the specs have been executed; it is best done from
  # within the +spec_helper.rb+ file during the load process.
  #
  GENERATION_CLASSES = [ 'Thor::Actions', 'Rails::Generators::Actions', 'Rails::Generators::Migration' ]
  
  attr_reader :method_name, :method_args
  
  def initialize(method_name, *args, &block)
    @method_name = method_name
    @method_args = args
    @actual_args = nil
    super(&block)
  end
  
  def report_actual_args(args)
    # save a reference to the set of args that most *closely* matched the expectation.
    return(@actual_args = args) if @actual_args.nil?
    matches = (method_args & args).length
    if matches > (method_args & @actual_args).length
      @actual_args = args
    end
  end
  
  def failure_message
    "expected to generate a call to #{method_name.inspect}#{with_args} but #{what}"
  end
  
  def negative_failure_message
    "expected not to generate a call to #{method_name.inspect}#{with_args} but it happened anyway"
  end
  
  private
  def with_args
    if @method_args.empty?
      ''
    else
      " "+@method_args.inspect
    end
  end
  
  def what
    if @actual_args.nil?
      "that did not happen"
    else
      "received #{@actual_args.inspect} instead"
    end
  end
  
  protected
  def invoking
    method_name = self.method_name
    interceptor = self
    generator.class_eval do
      no_tasks do
        define_method :"#{method_name}_with_intercept" do |*argus, &block|
          expected_args = interceptor.method_args
          if expected_args.length > 0
            actual_args = argus[0...expected_args.length]
            if actual_args == expected_args
              interceptor.match!
            else
              # we've already matched the method, and there are no expected args.
              interceptor.report_actual_args actual_args
            end
          else
            interceptor.match!
          end
          
          send(:"#{method_name}_without_intercept", *argus, &block)
        end

        alias_method :"#{method_name}_without_intercept", :"#{method_name}"
        alias_method :"#{method_name}", :"#{method_name}_with_intercept"
      end
    end
  end
  
  def complete
    # we couldn't subclass the generator anonymously because this dirties the
    # rails generator search process. Instead we'll rely on manually de-aliasing
    # the method being monitored.
    method_name = self.method_name
    generator.class_eval do
      no_tasks do
        alias_method :"#{method_name}", :"#{method_name}_without_intercept"
      end
    end
  end
  
  public
  class << self
    # Returns all public instance methods found in the modules listed in 
    # GENERATION_CLASSES. This is the list of methods that will be converted
    # into matchers, which can be used like so:
    #
    #   subject.should create_file(. . .)
    #
    # See also GENERATION_CLASSES
    #
    def generation_methods
      GENERATION_CLASSES.inject([]) do |arr, mod|
        if mod.kind_of?(String)
          next arr if !defined?(Rails) && mod =~ /^Rails/
          mod = mod.constantize
        end
        arr.concat mod.public_instance_methods.collect { |i| i.to_s }.reject { |i| i =~ /=/ }
        arr
      end.uniq.sort
    end
    
    # called from GenSpec::Matchers#call_action
    # 
    # example:
    #   subject.should call_action(:create_file, ...)
    #
    # equivalent to:
    #   subject.should GenSpec::Matchers::GenerationMethodMatcher.for_method(:create_file, ...)
    #
    def for_method(which, *args, &block)
      if generation_methods.include?(which.to_s)
        new(which, *args, &block)
      else
        raise "Could not find a matcher for '#{which.inspect}'!\n\n" \
              "If this is a custom action, try adding the Thor Action module to GenSpec:\n\n" \
              "  GenSpec::Matchers::GenerationMethodMatcher::GENERATION_CLASSES << 'My::Actions'"
      end
    end
  end
end
