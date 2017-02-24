require 'coveralls'
Coveralls.wear!

lib = File.expand_path('../../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vagrant/devcommands'

require_relative '../helpers/ui'
