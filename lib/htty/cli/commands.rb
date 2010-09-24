# Loads constants defined within HTTY::CLI::Commands.

module HTTY; end

class HTTY::CLI; end

# Contains classes that implement commands in the user interface.
module HTTY::CLI::Commands
  
  class CommandSet
    attr_accessor :commands
    
    include Enumerable
    
    def initialize(*folders)
      folders.each do |f|
        self.commands += load_commands(f)
      end
    end
    
    def commands
      @commands ||= []
    end
    
    # Returns a HTTY::CLI::Command descendant whose command line representation
    # matches the specified _command_line_. If an _attributes_ hash is specified,
    # it is used to initialize the command.
    def build_for(command_line, attributes={})
      each do |klass|
        if (command = klass.build_for(command_line, attributes))
          return command
        end
      end
      nil
    end
    
    def each
      commands.each do |c|
        yield c
      end
    end
    
    def load_commands(folder)
      Dir.glob(File.join(folder, "*.rb")).map do |f|
        require f
        
        class_name = File.basename(f, '.rb').gsub(/^(.)/) do |initial|
          initial.upcase
        end.gsub(/_(\S)/) do |initial|
          initial.gsub(/_/, '').upcase
        end

        klass = HTTY::CLI::Commands::const_get(class_name) rescue nil
      end
    end
  end
end