module SimpleMonkey

  module Utils

    def system(cmd)
      puts "running: [#{cmd}]" if @debug
      fail "\n  Failed to run [#{cmd}]\n  in [#{Dir.pwd}]" unless
        Kernel::system(cmd)
    end

    def systemFailOK(cmd)
      puts "running: [#{cmd}]" if @debug
      puts "\n  Failed (OK) to run [#{cmd}]\n  in [#{Dir.pwd}]" unless
        Kernel::system(cmd)
    end

  end
end
