require 'vagrant'

I18n.load_path << File.expand_path('../../../locales/en.yml', __FILE__)
I18n.reload!

require 'vagrant/devcommands/synopsis'
require 'vagrant/devcommands/version'

require 'vagrant/devcommands/internal_spec'
require 'vagrant/devcommands/messages'
require 'vagrant/devcommands/util'

require 'vagrant/devcommands/model/chain'
require 'vagrant/devcommands/model/command'

require 'vagrant/devcommands/internal_command/help'
require 'vagrant/devcommands/internal_command/version'

require 'vagrant/devcommands/command'
require 'vagrant/devcommands/command_file'
require 'vagrant/devcommands/internal'
require 'vagrant/devcommands/plugin'
require 'vagrant/devcommands/registry'
