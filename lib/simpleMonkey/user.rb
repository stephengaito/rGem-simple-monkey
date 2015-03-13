module SimpleMonkey

  module User

    def setup
      Config['homeDir'] = Config['userKeyDir']
    end

  end

end

