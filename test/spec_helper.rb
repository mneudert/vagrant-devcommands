if ENV.key?('TRAVIS_COVERAGE') && ENV['TRAVIS_COVERAGE'] == 'true'
  require 'coveralls'
  Coveralls.wear!
end

require 'vagrant/devcommands'

require_relative './helpers/ui'
require_relative './helpers/commandfile_cwd_context'
