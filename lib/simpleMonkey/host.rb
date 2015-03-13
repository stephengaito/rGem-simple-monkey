

module SimpleMonkey

  module Host

    def setup
      @debug = Config['debug']
      #
      # setup and ensure GnuPG's homeDir (@keyDir) exists
      #
      @keyDir = Config['hostKeyDir']
      FileUtils.mkdir_p(@keyDir)
      FileUtils.chmod(0700, @keyDir)
      #
      # setup various variables
      #
      @keyUID = Config['hostKeyUid']
      @sshKey = Config['hostSshKey']
      #
      @internalKeyServer = Config['internalKeyServer']
      @externalKeyServer = Config['externalKeyServer']
    end

  end

end
