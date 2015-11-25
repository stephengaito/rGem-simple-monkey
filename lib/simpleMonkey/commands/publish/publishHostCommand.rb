
require 'simpleMonkey/commands/publishCommand'

module SimpleMonkey

  class PublishHostCommand < PublishCommand
    extend Host

    class << self

      def doPublishHostCommand
        setup
        getSysAdminKeys
        refreshKeys
        loadSshKeys
        sshKeys = YAML.dump(@sshKeyData)
        puts sshKeys if @debug
        hostIdentity = ""
        @sysAdmins.each do | aSysAdmin |
          encryptedFile = encryptFile(aSysAdmin, sshKeys)
          puts encryptedFile if @debug
          hostIdentity << encryptedFile
        end
        puts "host identity" if @debug
        puts hostIdentity if @debug
        @sshKeyData.each_pair do | keyType, keyData |
          keyData.delete('asciiData')
        end

        identityHash = Hash.new
        identityHash['status']    = 'published'
        identityHash['role']      = 'machine'
        identityHash['userID']    = @keyUID
        identityHash['userKeyID'] = createUserKeyID(@keyUID)
        identityHash['hostName']  = @keyUID
        identityHash['hostIP']    = Config['hostIP']
        # Our SimpleHKP indentity protocol requires a hexadecimal userKeyID..
        identityHash['sysAdmins'] = @sysAdmins
        identityHash['sshKeys']   = @sshKeyData
        pp identityHash if @debug
        pushIdentity(identityHash, hostIdentity)
return
        loadKeyData
        findIdentities
        return
#        if convertedKeySSH2GPG(@keyUID) then
#          loadKeyData
#          keyIDs = findKeys(@keyUID)
#          if keyIDs.size == 1 then
#            puts "Pushing key: [#{keyIDs[0]}]" if @debug
#            pushKey(keyIDs[0]) 
#          else
#            puts "WARNING Too many/few valid [#{@keyUID}] keys found:"
#            pp keyIDs
#          end
#        else
#          puts "WARNING Could not convert key from SSH 2 gpg"
#        end
      end

      def init_with_command(c)
        c.command(:host) do | sc |
          sc.syntax 'host [options]'
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
