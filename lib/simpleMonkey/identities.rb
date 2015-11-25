require 'uri'
require 'net/http'

module SimpleMonkey

  module Identities

    def convertToHttp(aKeyServerStr)
      aKeyServerStr = aKeyServerStr+':11371' unless
        aKeyServerStr =~ /:/
      aKeyServerStr = 'http://'+aKeyServerStr unless 
        aKeyServerStr =~ /^http/
      aKeyServerStr
    end

    def findIdentities
      puts @internalKeyServer if @debug
      keyServer = convertToHttp(@internalKeyServer)

      keyServerSearch = "#{keyServer}/pis/lookup?search=#{@keyUID}&op=index&options=mr"
      puts keyServerSearch if @debug
      url = URI.parse(keyServerSearch)

      identities = Array.new
      response = Net::HTTP.get_response(url)
      response.body.each_line do | aLine |
        next unless aLine =~ /^idn/
        puts aLine
        identities.push(aLine.split(/:/)[1])
      end
      pp identities if @debug
      identities
    end

    def createUserKeyID(userIDstr)
      #
      # Our SimpleHKP identity protocol requires a **hexadecimal** userKeyID
      # so we create one by encoding the contents of a string as hexadecimal
      #
      userIDstr.unpack('H*').first.upcase.encode(Encoding::UTF_8)
    end

    def pushIdentity(identityHeaderHash, identityContents)
      if !identityHeaderHash.has_key?('role') ||
         !identityHeaderHash.has_key?('userID') then
        puts "WARNING no role and/or userID found"
        pp identityHeaderHash
      end
      identityHeader = YAML.dump(identityHeaderHash)
      identity = identityHeader
      identity << "---\n"
      identity << identityContents
      puts identity if @debug

      puts @internalKeyServer if @debug
      keyServer = convertToHttp(@internalKeyServer)

      keyServerAdd = keyServer+'/pis/add'
      puts keyServerAdd if @debug
      url = URI.parse(keyServerAdd)
      Net::HTTP.post_form(url, { 'keytext' => identity })
    end

#          url = URI.parse(fromKeyServer+"/pis/lookup?op=get&options=mr&search=#{anIdFile}")
#          response = Net::HTTP.get_response(url)
#          idData = response.body
#          puts anIdFile if debug
#          puts idData if debug


  end

end
