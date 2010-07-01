module GenSpec
  # Just like a Thor::Shell::Basic except that input and output are both redirected to
  # the specified streams. By default, these are initialized to instances of StringIO.
  class Shell < Thor::Shell::Basic
    attr_accessor :input, :output
    
    def initialize(output="", input="")
      super()
      new(output, input)
    end
    
    # Reinitializes this Shell with the given input and output streams.
    def new(output="", input="")
      init_stream(:output, output)
      init_stream(:input,  input)
      self
    end
    
    # Ask something to the user and receives a response.
    #
    # ==== Example
    # ask("What is your name?")
    #
    def ask(statement, color=nil)
      say("#{statement} ", color)
      input.gets.strip
    end

    # Say (print) something to the user. If the sentence ends with a whitespace
    # or tab character, a new line is not appended (print + flush). Otherwise
    # are passed straight to puts (behavior got from Highline).
    #
    # ==== Example
    # say("I know you knew that.")
    #
    def say(message="", color=nil, force_new_line=(message.to_s !~ /( |\t)$/))
      message  = message.to_s
      message  = set_color(message, color) if color

      if force_new_line
        output.puts(message)
      else
        output.print(message)
        output.flush
      end
    end

    # Prints a table.
    #
    # ==== Parameters
    # Array[Array[String, String, ...]]
    #
    # ==== Options
    # ident<Integer>:: Ident the first column by ident value.
    #
    def print_table(table, options={})
      return if table.empty?

      formats, ident = [], options[:ident].to_i
      options[:truncate] = terminal_width if options[:truncate] == true

      0.upto(table.first.length - 2) do |i|
        maxima = table.max{ |a,b| a[i].size <=> b[i].size }[i].size
        formats << "%-#{maxima + 2}s"
      end

      formats[0] = formats[0].insert(0, " " * ident)
      formats << "%s"

      table.each do |row|
        sentence = ""

        row.each_with_index do |column, i|
          sentence << formats[i] % column.to_s
        end

        sentence = truncate(sentence, options[:truncate]) if options[:truncate]
        output.puts sentence  
      end
    end

    # Called if something goes wrong during the execution. This is used by Thor
    # internally and should not be used inside your scripts. If someone went
    # wrong, you can always raise an exception. If you raise a Thor::Error, it
    # will be rescued and wrapped in the method below.
    #
    def error(statement)
      output.puts statement
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