require 'open3'

module SimpleMonkey

  module Keys

    def saveLastKey(lastKey)
      lastKey['colonData'].gsub!(/\\x3a/,':') if 
        lastKey.has_key?('colonData')
      pp lastKey if @debug
      @keyData[lastKey['keyID']] = lastKey unless 
        lastKey.empty? || lastKey['keyID'].empty?
    end

    def loadKeyData
      @keyData = Hash.new
      puts "SimpleMonkey: loading key data" if @debug
      gpg2cmd = "gpg2 --homedir #{@keyDir} --with-fingerprint --with-colons --check-sigs"
      puts gpg2cmd if @debug
      lastKey = Hash.new
      IO.popen(gpg2cmd, 'r') do | gpgPipe |
        gpgPipe.readlines.each do | aLine |
          next if aLine =~ /^tru/
          if aLine =~ /^pub/ then
            saveLastKey(lastKey)
            lastKey = Hash.new
            keyData = aLine.split(/:/)
            lastKey['userID']    = keyData[9].gsub(/\\x3a/,':') # user ID
            lastKey['keyID']     = keyData[4] #  key ID
            lastKey['algorithm'] = keyData[3] #  key type (algorithm)
            lastKey['length']    = keyData[2] #  key length
            lastKey['created']   = keyData[5] #  creation date
            lastKey['expires']   = keyData[6] #  expiration date
            lastKey['flags']     = keyData[1] #  flags
            lastKey['colonData'] = aLine
            next
          end
          lastKey['userID'] = aLine.split(/:/)[9].gsub(/\\x3a/,':') if
            aLine =~ /^uid/ && lastKey['userID'].empty?
          lastKey['colonData'] << aLine
        end
      end
      saveLastKey(lastKey)
      @keyData.each_pair do | key, value |
        gpg2cmd = "gpg2 --homedir #{@keyDir} --list-sig #{key}"
        puts gpg2cmd if @debug
        IO.popen(gpg2cmd) do | gpgPipe |
          value['humanData'] = gpgPipe.read
        end
      end
      pp @keyData if @debug
      puts "SimpleMonkey: finished loading keys" if @debug
    end

    def getSysAdminKeys
      @sysAdmins = [ @sysAdmins ] unless @sysAdmins.is_a?(Array)
      @sysAdmins.each do | aSysAdmin |
        puts "Getting system admin key:\n  [#{aSysAdmin}]\n from [#{@internalKeyServer}] (internal)" if @debug
        systemFailOK("gpg2 --homedir #{@keyDir} --keyserver #{@internalKeyServer} --recv-keys #{aSysAdmin}")
        puts "Getting system admin key:\n  [#{aSysAdmin}]\n from [#{@externalKeyServer}] (external)" if @debug
        systemFailOK("gpg2 --homedir #{@keyDir} --keyserver #{@externalKeyServer} --recv-keys #{aSysAdmin}")
      end
    end

    def refreshKeys
      puts "Refreshing keys from [#{@internalKeyServer}] (internal)" if @debug
      systemFailOK("gpg2 --homedir #{@keyDir} --keyserver #{@internalKeyServer} --refresh-keys")
      puts "Refreshing keys from [#{@externalKeyServer}] (external)" if @debug
      systemFailOK("gpg2 --homedir #{@keyDir} --keyserver #{@externalKeyServer} --refresh-keys")
    end

    def findKeys(keyRegexpStr)
      keyRegexp = Regexp.new(keyRegexpStr, 
                             Regexp::IGNORECASE | Regexp::MULTILINE )
      keyIDs = Array.new
      @keyData.each_pair do | key, keyData |
        next unless keyData['colonData'] =~ keyRegexp
        next if keyData['flags'] =~ /r/i # ignore revoked keys
        keyIDs.push(key)
      end
      keyIDs
    end

    def pushKey(keyID)
      system("gpg2 --homedir #{@keyDir} --keyserver #{@internalKeyServer} --send-key #{keyID}")
    end

    def encryptFile(keyID, fileContents)
      encryptedFile = ""
      gpg2cmd = "gpg2 --homedir #{@keyDir} --yes --armor --output - --encrypt --recipient #{keyID} --trusted-key #{keyID}"
      puts gpg2cmd if @debug
      Open3.popen2(gpg2cmd) do | gpg2In, gpg2Out, gpg2Thread |
        gpg2In.write(fileContents)
        gpg2In.close
        encryptedFile = gpg2Out.read
      end
      puts encryptedFile if @debug
      encryptedFile
    end

  end

end

