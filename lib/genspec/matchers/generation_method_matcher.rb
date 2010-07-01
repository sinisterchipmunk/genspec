class GenSpec::Matchers::GenerationMethodMatcher < GenSpec::Matchers::Base
  GENERATION_CLASSES = [ 'Thor::Actions', 'Rails::Generators::Actions' ]
  
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
    matches = (method_args % args).length
    if matches > (method_args % @actual_args).length
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
    silence_thor! do
      generator.class_eval <<-end_code
        def #{method_name}_with_intercept(*argus, &block)
          expected_args = self.class.interceptor.method_args
          if expected_args.length > 0
            actual_args = argus[0...expected_args.length]
            if actual_args == expected_args
              self.class.interceptor.match!
            else
              self.class.interceptor.report_actual_args(actual_args)
            end
          else
            # we've already matched the method, and there are no expected args.
            self.class.interceptor.match!
          end

          #{method_name}_without_intercept(*argus, &block)
        end
      end_code
      generator.send(:alias_method_chain, method_name, :intercept)
    end    
  end
  
  public
  class << self
    def generation_methods
      GENERATION_CLASSES.inject([]) do |arr, mod|
        mod = mod.constantize if mod.kind_of?(String)
        arr.concat mod.public_instance_methods.collect { |i| i.to_s }.reject { |i| i =~ /=/ }
        arr
      end
    end
    
    def for_method(which, *args, &block)
      if generation_methods.include?(which.to_s) then self.new(which, *args, &block)
      else nil
      end
    end
  end
end
