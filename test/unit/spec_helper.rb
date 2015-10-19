lib = File.expand_path('../../../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vagrant/devcommands'

# global configuration and state manipulation
RSpec.configure do |config|
  # global alias constant
  config.before :each do
    VagrantPlugins::DevCommands::Definer.commands = {}
  end
end
