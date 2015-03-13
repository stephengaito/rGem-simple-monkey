
module SimpleMonkey

  class PublishHostCommand < SubCommand
    extend Utils
    extend Host
    extend GnuPG

    def self.init_with_command(c)
      c.command(:host) do | sc |
        sc.syntax 'publish host [options]'
        sc.description "publishes a host's existing OpenSSH key"

        sc.action do | args, options |
          Config.loadConfiguration(options)
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
          end
        end

      end
    end


  end

end
