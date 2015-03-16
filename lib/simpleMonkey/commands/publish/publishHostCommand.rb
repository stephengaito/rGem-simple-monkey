
require 'simpleMonkey/commands/publishCommand'

module SimpleMonkey

  class PublishHostCommand < PublishCommand
    extend Host

    class << self

      def doPublishHostCommand
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
          sc.syntax 'publish host [options]'
          sc.description "publishes a host's existing OpenSSH key (must be run as root)"

          sc.action do | args, options |
            if isRoot? then
              Config.loadConfiguration(options)
              doPublishHostCommand
            else
              puts "\nThis command MUST be run as root\n\n"
              puts sc
            end
          end
        end
      end

    end
  end
end
