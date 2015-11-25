
require 'simpleMonkey/commands/confirmCommand'

module SimpleMonkey

  class ConfirmHostCommand < ConfirmCommand
    extend Host

    class << self

      def doConfirmHostCommand
        setup
        refreshKeys
        loadKeyData
        if convertedKeySSH2GPG(@keyUID) then
          loadKeyData
          keyIDs = findKeys(@keyUID)
          if keyIDs.size == 1 then
            puts "Pushing key: [#{keyIDs[0]}]" if @debug
            pushKey(keyIDs[0]) 
          else
            puts "WARNING Too many/few valid [#{@keyUID}] keys found:"
            pp keyIDs
          end
        else
          puts "WARNING Could not convert key from SSH 2 gpg"
        end
      end

      def init_with_command(c)
        c.command(:host) do | sc |
          sc.syntax 'confirm host <<host name>> [options]'
          sc.description "used by a SystemAdmin to confirm a host's existing OpenSSH key"

          sc.action do | args, options |
            Config.loadConfiguration(options)
            doConfirmHostCommand
          end
        end
      end

    end
  end
end
