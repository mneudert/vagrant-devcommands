module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "version" command
      class Version
        SPEC = {
          desc: 'display currently used the plugin version',
          name: 'version'
        }

        def execute
          puts "vagrant-devcommands, version #{VERSION}"
        end
      end
    end
  end
end
