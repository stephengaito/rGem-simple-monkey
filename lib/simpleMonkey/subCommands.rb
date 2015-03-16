
module SimpleMonkey
  module SubCommand

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

