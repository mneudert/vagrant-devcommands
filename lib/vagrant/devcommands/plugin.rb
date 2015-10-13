module VagrantPlugins
  module DevCommands
    # Vagrant plugin definition
    class Plugin < Vagrant.plugin(2)
      name 'vagrant-devcommands'
      description 'Runs vagrant commands from a Commandfile'

      command :run do
        require_relative 'command'
        Command
      end
    end
  end
end
