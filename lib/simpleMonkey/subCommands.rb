# We probably SHOULD use Mercenary::Command instead of simply Command 
# here as this would allow us to use a number of useful features (such 
# as logging)... however I think we would still need to define the 
# methods below.
#

module SimpleMonkey
  class SubCommand < Mercenary::Command
    class << self

      def inherited(base)
        subclasses << base
      end

      def subclasses
        @subclasses ||= []
      end

      def init_with_command(p)
        raise NotImplementedError.new("")
      end

    end
  end
end

