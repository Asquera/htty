# Defines HTTY::CLI and loads constants defined within HTTY::CLI.
require 'readline'
require File.expand_path("#{File.dirname __FILE__}/cli/commands")
require File.expand_path("#{File.dirname __FILE__}/cli/commands/help")
require File.expand_path("#{File.dirname __FILE__}/cli/commands/quit")
require File.expand_path("#{File.dirname __FILE__}/cli/display")
require File.expand_path("#{File.dirname __FILE__}/session")

module HTTY; end

# Encapsulates the command-line interface to _htty_.
class HTTY::CLI
  include HTTY::CLI::Display

  # Returns the HTTY::Session created from command-line arguments.
  attr_reader :session
  
  def self.instance=(cli)
    @instance = cli
  end
  
  def self.instance
    @instance
  end

  # Instantiates a new HTTY::CLI with the specified _command_line_arguments_.
  def initialize(command_line_arguments, session_class = HTTY::Session)
    exit unless @session = rescuing_from(ArgumentError) do
      everything_but_options = command_line_arguments.reject do |a|
        a[0..0] == '-'
      end
      session_class.new(everything_but_options.first)
    end
    HTTY::CLI.instance = self
  end

  # Takes over stdin, stdout, and stderr to expose #session to command-line
  # interaction.
  def run!
    say_hello
    catch :quit do
      loop do
        begin
          unless (command = prompt_for_command)
            $stderr.puts notice('Unrecognized command')
            puts notice('Try typing ' +
                        strong(HTTY::CLI::Commands::Help.command_line))
            next
          end
          if ARGV.include?('--debug')
            command.perform
          else
            rescuing_from Exception do
              command.perform
            end
          end
        rescue Interrupt
          puts
          puts notice('Type ' +
                      strong(HTTY::CLI::Commands::Quit.command_line) +
                      ' to quit')
          next
        end
      end
    end
    say_goodbye
  end
  
  def commands
    @commands ||= HTTY::CLI::Commands::CommandSet.new(*command_folders)
  end

private

  def prompt_for_command
    command_line = ''
    while command_line.empty? do
      if (command_line = Readline.readline(prompt, true)).nil?
        raise Interrupt
      end
      command_line.chomp.strip!
    end
    commands.build_for command_line, :session => session
  end

  def prompt
    strong(session.requests.last.uri) + normal('> ')
  end
  
  
  def command_folders
    ["#{File.dirname __FILE__}/cli/commands"]
  end

end

Dir.glob "#{File.dirname __FILE__}/cli/*.rb" do |f|
  require File.expand_path("#{File.dirname __FILE__}/cli/" +
                           File.basename(f, '.rb'))
end
