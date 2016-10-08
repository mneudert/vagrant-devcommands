module VagrantPlugins
  module DevCommands
    # Vagrant plugin definition
    class Plugin < Vagrant.plugin(2)
      name 'vagrant-devcommands'
      description VagrantPlugins::DevCommands::SYNOPSIS

      command :run do
        Command
      end
    end
  end
end
