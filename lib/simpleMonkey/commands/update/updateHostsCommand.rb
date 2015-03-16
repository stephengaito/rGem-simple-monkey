require 'simpleMonkey/commands/updateCommand'

module SimpleMonkey

  class UpdateHostsCommand < UpdateCommand

    class << self

      def doUpdateHostsUserCommand
        extend User

        setup
        refreshKeys
        loadKeyData
      end

      def doUpdateHostsAllCommand
      end

      def doUpdateHostsSystemCommand
        extend Host

        setup
        refreshKeys
        getKeysFromInternalKeyServer('sysAdmin')
        getKeysFromInternalKeyServer('machine')
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

      def init_with_command(c)
        c.command(:hosts) do | sc |
          sc.syntax 'update hosts [options]'
          sc.description "updates the known_hosts files for eithe a user, all users or the system (the 'smonkey update hosts {all|system}' commands must be run as root)"

          sc.action do | args, options |
            Config.loadConfiguration(options)
            if args.empty? the
              puts "please specify one of 'user', 'all', or 'system'"
              puts sc
            else
              case args[0]
              when 'user'
              when 'all'
                if isRoot? then
                  doUpdateHostsAllCommand
                else
                  puts "you MUST be root to run the 'smonkey update hosts all' command"
                  puts sc
                end
              when 'system'
                if isRoot? then
                  doUpdateHostsSystemCommand
                else
                  puts "you MUST be root to run the 'smonkey update hosts system' command"
                  puts sc
                end
              end
            end
          end
        end
      end

    end
  end
end

