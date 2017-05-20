module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "version" command
      class Version
        def initialize(env)
          @env = env
        end

        def execute(_argv)
          @env.ui.info "vagrant-devcommands, version #{VERSION}"
        end
      end
    end
  end
end
