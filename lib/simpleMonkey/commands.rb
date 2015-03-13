# We probably SHOULD use Mercenary::Command instead of simply Command 
# here as this would allow us to use a number of useful features (such 
# as logging)... however I think we would still need to define the 
# methods below.
#
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

      def system(cmd)
        fail "\n  Failed to run [#{cmd}]\n  in [#{Dir.pwd}]" unless
          Kernel::system(cmd)
      end

      def doIn(subDir, &block)
        if Dir.exists?(subDir) then
          Dir.chdir(subDir, &block)
        else
          block.call()
        end
      end

      def doIfNeeded(dependent, dependencies, &block)
        dependencies = [ dependencies ] if dependencies.is_a?(String)
        block.call() unless FileUtils.uptodate?(dependent, dependencies)
      end

    end
  end
end

