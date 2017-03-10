if ENV.key?('TRAVIS_COVERAGE') && 'true' == ENV['TRAVIS_COVERAGE']
  require 'coveralls'
  Coveralls.wear!
end

require 'vagrant/devcommands'

require_relative './helpers/ui'
