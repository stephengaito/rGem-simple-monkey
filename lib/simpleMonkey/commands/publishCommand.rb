
module SimpleMonkey

  class PublishCommand < Command
    extend SubCommand
    extend Utils
    extend Keys
    extend Identities
    extend SSH

    class << self

      def init_with_program(p)
        p.command(:publish) do | c |
          c.syntax 'publish <subcommand> [options]'
          c.description "publishes a user's or host's existing OpenSSH key"
          c.action do | args, options |
            c.logger.error "You must specify either user or host"
            puts c
          end
          SimpleMonkey::PublishCommand.subclasses.each do | subCmd |
            subCmd.init_with_command(c)
          end
        end
      end

    end


  end

end
