
module SimpleMonkey

  class UpdateCommand < Command
    extend SubCommand
    extend Utils
    extend GnuPG

    class << self

      def init_with_program(p)
        p.command(:update) do | c |
          c.syntax 'update {keys|hosts} [options]'
          c.description "updates a user's or system's authorized_keys or known_hosts files"
          c.action do | args, options |
            c.logger.error "You must specify either keys or hosts"
            puts c
          end
          SimpleMonkey::UpdateCommand.subclasses.each do | subCmd |
            subCmd.init_with_command(c)
          end
        end
      end

    end

  end

end
