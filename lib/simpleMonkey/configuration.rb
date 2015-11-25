
require 'safe_yaml'
require 'socket'

module SimpleMonkey

  class Config

    @@options = Hash.new

    DEFAULTS = {
      'config' => '/etc/simpleMonkeyConfig.yaml',
      'debug'  => false,
      'systemAdminFingerPrints' => [
        'unknown'
      ],
      'hostKeyDir' => '/var/lib/simpleMonkey/hostKeyDir',
      'userKeyDir' => ENV['HOME']+'/.gnupg',
      'internalKeyServer' => 'unknown', 
      'externalKeyServer' => 'pool.sks-keyservers.net',
      'hostKeyUid' => Socket.gethostname.encode(Encoding::UTF_8),
      'hostIP'     => Socket.ip_address_list.reject{ | ipObj | ipObj.ipv6? }.collect{ | ipObj | ipObj.ip_address.encode(Encoding::UTF_8) },
      'userKeyUid' => ENV['USER'],
      'hostSshKeys' => [
        '/etc/ssh/ssh_host_ecdsa_key.pub',
        '/etc/ssh/ssh_host_rsa_key.pub',
        '/etc/ssh/ssh_host_dsa_key.pub'
      ],
      'userSshKeys' => [
        ENV['HOME'] + '/.ssh/id_rsa.pub'
      ]
    }

    class << self

      def options
        @@options
      end

      def [](aKey)
        @@options[aKey]
      end

      def []=(aKey, aValue)
        @@options[aKey] = aValue
      end

      def has_key?(aKey)
        @@options.has_key?(aKey)
      end

      def load_file(yamlFileName)
        loadedHash = SafeYAML::load_file(yamlFileName)
        @@options.merge!(loadedHash) if loadedHash
      end

      def loadConfiguration(options = {})
        #
        # Start by merging in the DEFAULTS
        #
        @@options.merge!(DEFAULTS)
        #
        # Now merge in the configuration YAML file
        #
        configFile = @@options['config']
        configFile = options['config'] if options.has_key?('config')
        load_file(configFile) if File.exists?(configFile)
        #
        # Now merge in the command line options
        #
        @@options.merge!(options)
        #
        # explicilty list the configuration
        #
        @debug = @@options['debug']
        if @debug then
          puts "\n----------------------------------------------------------"
          puts "Configuration:"
          puts "----------------------------------------------------------"
          pp @@options
          puts "----------------------------------------------------------\n\n"
        end
      end

    end

  end

end
