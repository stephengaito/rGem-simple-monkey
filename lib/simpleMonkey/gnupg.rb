require 'open3'

module SimpleMonkey

  module GnuPG

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
            lastKey['len']       = keyData[2] #  key length
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
        value['humanData'] = `gpg2 --homedir #{@keyDir} --list-sig #{key}`
      end
      pp @keyData if @debug
      puts "SimpleMonkey: finished loading keys" if @debug
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

    def convertedKeySSH2GPG(keyUID)
      keyIDs = findKeys(keyUID)
      case keyIDs.size
      when 1
        puts "SSH key [#{@sshKey}] with key UID [#{keyUID}] already converted" if @debug
        return true
      when 0
        puts "Creating new openPGP key from [#{@sshKey}] with key UID [#{keyUID}]" if @debug
        sshKey = File.read(@sshKey)
        return false if sshKey.empty?
        gpgKey = ""
        pemCmd = "pem2openpgp #{keyUID}"
        puts pemCmd if @debug
        Open3.popen2(pemCmd) do | pemStdIn, pemStdOut, wait_thr |
          pemStdIn.write(sshKey)
          pemStdIn.close
          gpgKey = pemStdOut.read
          pemStdOut.close
        end
        return false if gpgKey.empty?
        gpg2Cmd = "gpg2 --homedir #{@keyDir} --import"
        puts gpg2Cmd if @debug
        IO.popen(gpg2Cmd, 'w') do | gpgPipe |
          gpgPipe.write(gpgKey)
        end
        result = $?
        pp result if @debug
        return result
      end
      puts "Too many keys with the key UID of [#{keyUID}]"
      return false
    end

    def pushKey(keyID)
      system("gpg2 --homedir #{@keyDir} --keyserver #{@internalKeyServer} --send-key #{keyID}")
    end

  end

end

