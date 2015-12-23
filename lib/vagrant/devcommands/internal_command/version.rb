module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "version" command
      class Version
        SPEC = {
          desc: 'display currently used the plugin version',
          name: 'version',
          help: <<-eoh
Displays the currently installed version the plugin you are using right now.
eoh
        }

        def execute(_args)
          puts "vagrant-devcommands, version #{VERSION}"
        end
      end
    end
  end
end
