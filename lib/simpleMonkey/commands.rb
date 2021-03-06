# We probably SHOULD use Mercenary::Command instead of simply Command 
# here as this would allow us to use a number of useful features (such 
# as logging)... however I think we would still need to define the 
# methods below.
#

require 'simpleMonkey/subCommands'

module SimpleMonkey
  class Command < Mercenary::Command
    class << self

      def inherited(base)
        subclasses << base
      end

      def subclasses
        @subclasses ||= []
      end

      def init_with_program(p)
        raise NotImplementedError.new("")
      end

    end
  end
end

# Automatically require all known commands
#
Dir.chdir(File.dirname(__FILE__)) do 
  $LOAD_PATH << Dir.pwd
  Dir[File.join("commands", "**", "*.rb")].sort.each do |f|
    #puts "Requiring [#{f}]"
    require f
  end
end

