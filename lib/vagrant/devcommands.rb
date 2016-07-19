require 'vagrant'

I18n.load_path << File.expand_path('../../../locales/en.yml', __FILE__)
I18n.reload!

require 'vagrant/devcommands/internal_spec'
require 'vagrant/devcommands/util'

require 'vagrant/devcommands/internal_command/help'
require 'vagrant/devcommands/internal_command/version'

require 'vagrant/devcommands/command'
require 'vagrant/devcommands/command_def'
require 'vagrant/devcommands/command_file'
require 'vagrant/devcommands/internal'
require 'vagrant/devcommands/plugin'
require 'vagrant/devcommands/registry'
require 'vagrant/devcommands/version'
