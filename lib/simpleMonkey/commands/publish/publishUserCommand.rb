
require 'simpleMonkey/commands/publishCommand'

module SimpleMonkey

  class PublishUserCommand < PublishCommand

    def self.init_with_command(c)
      c.command(:user) do | sc |
        sc.syntax 'publish user [options]'
        sc.description "publishes a user's existing OpenSSH key"
        sc.action do | args, options |
          Config.loadConfiguration(options)
          puts "user stuff to do!"
        end
      end
    end


  end

end
