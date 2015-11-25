
module SimpleMonkey

  module SSH

    def loadSshKeys
      @sshKeyData = Hash.new
      @sshKeys = [ @sshKeys ] unless @sshKeys.is_a?(Array)
      @sshKeys.each do | anSshKey |
        sshCmd = "ssh-keygen -lf #{anSshKey}"
        puts sshCmd if @debug
        keyData = ""
        IO.popen(sshCmd, 'r') do | sshPipe |
          keyData = sshPipe.read.chomp
        end
        next if keyData.empty?
        keyData = keyData.split
        keyHash = Hash.new
        keyHash['length']      = keyData.shift
        keyHash['fingerprint'] = keyData.shift
        keyHash['uid']         = keyData.shift
        keyHash['algorithm']   = keyData.shift
        keyHash['created']     = File.ctime(anSshKey).to_i
        keyHash['asciiData']   = File.read(anSshKey)
        algorithm = keyHash['asciiData'].split[0]
        next if algorithm.nil?
        @sshKeyData[algorithm] = keyHash
      end
      pp @sshKeyData if @debug
    end

  end

end
