
module SimpleMonkey

  class ConfirmCommand < Command
    extend SubCommand
    extend Utils
    extend Keys
    extend Identities
    extend SSH

    class << self

      def init_with_program(p)
        p.command(:confirm) do | c |
          c.syntax 'update {keys|hosts} [options]'
          c.description "used by the SystemAdmin to confirm a host's or user's identity"
          c.action do | args, options |
            c.logger.error "You must specify either host or user"
            puts c
          end
          SimpleMonkey::ConfirmCommand.subclasses.each do | subCmd |
            subCmd.init_with_command(c)
          end
        end
      end

    end

  end

end
