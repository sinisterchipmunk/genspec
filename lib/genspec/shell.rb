require 'thor/shell/basic'

module GenSpec
  # Just like a Thor::Shell::Basic except that input and output are both redirected to
  # the specified streams. By default, these are initialized to instances of StringIO.
  class Shell < Thor::Shell::Basic
    attr_accessor :stdin, :stdout, :stderr
    alias_method :input,   :stdin
    alias_method :input=,  :stdin=
    alias_method :output,  :stdout
    alias_method :output=, :stdout=
    
    def ask(statement, color = nil)
      say "#{statement} ", color
      response = stdin.gets
      if response
        response.strip
      else
        raise "Asked '#{statement}', but input.gets returned nil!"
      end
    end
    
    def initialize(output = "", input = "")
      super()
      new(output, input)
    end
    
    # Reinitializes this Shell with the given input and output streams.
    def new(output="", input="")
      init_stream(:output, output)
      init_stream(:input,  input)
      @stderr = @stdout
      self
    end

    private
    
    def init_stream(which, value)
      if value.kind_of?(String)
        value = StringIO.new(value)
      end
      send("#{which}=", value)
    end
  end
end