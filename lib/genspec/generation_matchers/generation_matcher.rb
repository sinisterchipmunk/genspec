module GenSpec
  module GenerationMatchers
    class GenerationMatcher
      delegate :generation_methods, :to => 'self.class'
      
      def initialize(kind = nil, *args)
        raise ArgumentError, "Call with kind" unless kind
        @kind = kind.to_s
        @args = args
        @but_found = nil
      end
          
      def self.generation_methods
        @generation_methods ||= %w(dependency class_collisions file template complex_template directory readme
                                   migration_template route_resources)
      end
      
      def matches?(target)
        # if it's a string then it's an error message or some such from the generator.
        if target.kind_of?(Rails::Generator::GeneratorError)
          # if we're not checking output then why hold on to it? Raise it like the error it is!
          raise target unless @kind == 'output'
          @log = target.message
        else
          temporary_root(target) do
            replay(target)
          end
        end
        match_content
        matched?
      end
      
      def failure_message
        "Expected to generate #{@kind}#{with_file}#{but_found}"
      end
      
      def negative_failure_message
        "Expected not to generate #{@kind}#{with_file}"
      end
      
      protected
      
      def replay(target)
        @create = Rails::Generator::Commands::Create.new(target)
        target.manifest.replay(self)
        after_replay(target)
      end
      
      # hook
      def after_replay(target)
      end
      
      def matched!
        @matched = true
      end
      
      def matched?
        !!@matched
      end
  
      private
      def temporary_root(target)
        # We could bear to split this into two methods, one called #suspend_logging or some such.
        original_root = target.instance_variable_get("@destination_root")
        original_logger = Rails::Generator::Base.logger
        original_quiet = target.logger.quiet
        @log = ""
  
        ### WHY does this not work? Instead we are forced to reroute the log output rather than just silence it.
        target.logger.quiet = true
        Rails::Generator::Base.logger = Rails::Generator::SimpleLogger.new(StringIO.new(@log))
  
        Dir.mktmpdir do |dir|
          # need to copy a few files for some methods, ie route_resources
          Dir.mkdir(File.join(dir, "config"))
          FileUtils.cp File.join(RAILS_ROOT, "config/routes.rb"), File.join(dir, "config/routes.rb")
          target.instance_variable_set("@destination_root", dir)
          yield
        end
      rescue
        if original_logger != Rails::Generator::Base.logger
          Kernel::raise $!.class, "#{$!.message}\n#{@log}", $!.backtrace
        else
          Kernel::raise $!
        end
      ensure
        Rails::Generator::Base.logger = original_logger
        target.logger.quiet = original_quiet
        target.instance_variable_set("@destination_root", original_root)
      end
      
      def match_content
        # check for a match if #kind is 'output'
        if @kind == 'output'
          @but_found = @log.dup
          if (text = @args.first).kind_of?(String)
            if @log =~ /#{Regexp::escape text}/m
              matched!
            end
          elsif (regexp = @args.first).kind_of?(Regexp)
            if @log =~ regexp
              matched!
            end
          end
        end
      end
  
      def but_found
        if @but_found.nil?
          ""
        else
          ",\n    but found #{@but_found.inspect}"
        end
      end
      
      def with_file
        !@args.empty? ? "\n    with #{@args.inspect}" : ""
      end
  
      def method_missing(name, *args, &block)
        if generation_methods.include? name.to_s
          @create.send(name, *args, &block)
          if name.to_s == @kind && (@args.empty? || args == @args)
            matched!
          elsif name.to_s == @kind
            @but_found = args
          else
            nil
          end
        else super
        end
      #rescue
      #  Kernel::raise $!.class, $!.message, caller
      end
    end
  end
end
